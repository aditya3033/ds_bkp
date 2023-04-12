from pyspark.sql.window import Window
from pyspark.sql.functions import *
from datetime import datetime
import time

from dependencies.utilities import *



def run(spark: SparkSession, config_dict: dict, module: str, sub_module: str, job: str, full_refresh: int = 0):
    print(f"Running {module}.{sub_module}.{job}")
    trigger_time = datetime.now()
    start_time = time.time()
    try:
        location_query = """(
                            SELECT UPPER(RTRIM(L.Location)) AS Location
                                ,L.Status
                                ,UPPER(RTRIM(L.CorpLocation)) AS CorpLocation
                                ,L.OwnManageLease
                                ,UPPER(RTRIM(L.OwnerLocation)) AS OwnerLocation
                                ,L.Name
                                ,L.AddressLine1
                                ,L.AddressLine2
                                ,L.City
                                ,L.State
                                ,L.Zip
                                ,L.Country
                                ,L.PhoneAreaCode
                                ,L.Phone
                                ,L.PhoneExtension
                                ,CASE 
                                    WHEN l.DateCreated BETWEEN '1/1/1985'
                                            AND getdate()
                                        THEN l.DateCreated
                                    END AS DateCreated
                                ,L.DateUpdated
                                ,L2.TypeCd
                                ,L2.TypeDesc
                                ,L2.DivisionCd
                                ,L2.DivisionNm
                                ,L2.MarketCd
                                ,L2.MarketNm
                                ,L.ForProfit AS ForProfitCd
                                ,ISNULL(cfp.description, 'Unknown') AS ForProfit
                                ,L2.CorpLocationNm
                                ,UPPER(RTRIM(L2.CorpContractCd)) AS CorpContractCd
                                ,L2.CorpContractNm
                                ,L2.CorpContractContractedPriceClass
                                ,isnull(cpb.BaseClass, '{N/A}') AS CorpContractBaseLevel
                                ,UPPER(RTRIM(L2.GPOContractCd)) AS GPOContractCd
                                ,L2.GPOContractNm
                                ,ISNULL(gc.PriceClass, '{N/A}') AS GPOContractPriceClass
                                ,ISNULL(gpb.BaseClass, '{N/A}') AS GPOContractBaseLevel
                                ,L2.AcuteCareBedCnt
                                ,L2.AlzheimersBedCnt
                                ,L2.AssistedLivingBedCnt
                                ,L2.HospiceBedCnt
                                ,L2.IndependentLivingBedCnt
                                ,L2.IntermediateCareBedCnt
                                ,L2.LongTermCareSkilledNursingBedCnt
                                ,L2.OtherBedCnt
                                ,L2.SubacuteCareBedCnt
                                ,L2.TotalBedCnt
                                ,L2.OwnerLocationNm
                                ,L2.CreditStatusDesc
                                ,L2.AccountManagerDivisionNm
                                ,L2.AccountManagerTeamNm
                                ,L2.AccountManagerNm
                                ,L2.CapitalSalesConsultantTeamNm
                                ,L2.CapitalSalesConsultantNm
                                ,L2.NationalAccountManagerTeamNm
                                ,L2.NationalAccountManagerNm
                            FROM MDID_BTRIEVE.dbo.ClLocn L
                            INNER JOIN FinProfit_DM.dbo.DimLocationCurrent AS L2 ON L2.SourceLocationId = l.Location
                            LEFT JOIN dshe_codes.dbo.CodeTranslation cfp ON cfp.CodeTypeID = 1363
                                AND cfp.Code1 = l.ForProfit
                                AND cfp.Code1 <> ''
                            LEFT JOIN mdid_btrieve.dbo.Clbasecl cpb ON cpb.Class = L2.CorpContractContractedPriceClass
                            LEFT JOIN mdid_btrieve.dbo.clcontyp gc ON gc.Contract = L2.GPOContractCd
                            LEFT JOIN mdid_btrieve.dbo.Clbasecl gpb ON gpb.Class = gc.PriceClass
                            WHERE L.Location <> ''
                        ) location_alias
                            """


        location_df = read_sql_dse(spark, config_dict, location_query)
        location_df = location_df.withColumnRenamed("DateCreated", "CreatedDate") \
                                 .withColumnRenamed("DateUpdated", "UpdatedDate") \
                                 .withColumnRenamed("PhoneExtension", "PhoneExt") \
                                 .withColumnRenamed("Status", "LocStatusCd") \
                                 .withColumnRenamed("Name", "DSELocName") \
                                 .withColumnRenamed("MarketNm", "Market") \
                                 .withColumnRenamed("TypeCd", "LocTypeCd") \
                                 .withColumnRenamed("TypeDesc", "LocType") \
                                 .withColumnRenamed("DivisionNm", "Division") \
                                 .withColumnRenamed("CorpContractBaseLevel", "LocCorpContractBaseClass") \
                                 .withColumnRenamed("CorpContractCd", "LocCorpContractCd") \
                                 .withColumnRenamed("CorpContractContractedPriceClass", "LocCorpContractPriceClass") \
                                 .withColumnRenamed("CorpContractNm", "LocCorpContractNm") \
                                 .withColumnRenamed("GPOContractBaseLevel", "LocGPOContractBaseClass") \
                                 .withColumnRenamed("GPOContractCd", "LocGPOContractCd") \
                                 .withColumnRenamed("GPOContractNm", "LocGPOContractNm") \
                                 .withColumnRenamed("GPOContractPriceClass", "LocGPOContractPriceClass") \
                                 .withColumn("DSLocationID", col("Location"))

        inserted_count = delta_merge(spark, config_dict, "dshe_dim_location_dse", location_df, full_refresh)
        
        print(f"{'/-'*40}")
        print(f"{'--'*40}")
    except Exception:
        end_time = time.time()
        elapsed_time = end_time - start_time
        exc_type, exc_msg, stack_trace = get_sys_exception()
        log_run_metrics(spark, config_dict, module, sub_module, job, "Failure", 0, elapsed_time, str(trigger_time), exc_type, exc_msg, stack_trace)
        print(f"{module}.{sub_module}.{job} job failed")
        print(f"{'/-'*10} Exception Type {'/-'*10}")
        print(exc_type)
        print(f"{'/-'*10} Exception Message {'/-'*10}")
        print(exc_msg)
        print(f"{'/-'*10} Stack Trace {'/-'*10}")
        print(stack_trace)
        spark.stop()
    else:     
        end_time = time.time()
        elapsed_time = end_time - start_time
        log_run_metrics(spark, config_dict, module, sub_module, job, "Success", inserted_count, elapsed_time, str(trigger_time), None, None, None)
        print(f"{module}.{sub_module}.{job} job ran successfully. Count = {inserted_count}")
    finally:
        print(f"Execution of {module}.{sub_module}.{job} job took {elapsed_time} seconds")