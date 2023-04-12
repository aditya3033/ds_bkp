from pyspark.sql import SparkSession
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
        # ---------------------------- Query > Column renaming map > writing to tables
        contact_dse_tbl = config_dict["dshe_dim_contact_dse"]["table"]
        contact_dssi_core_query = """
                                (SELECT UPPER(RTRIM(C.CustCode)) AS CustCode
                                    ,UPPER(RTRIM(C.CustLocNum)) AS CustLocNum
                                    ,C.CustContNum
                                    ,C.Username
                                    ,ISNULL(M.FirstName, C.Firstname) AS FirstName
                                    ,ISNULL(M.Lastname, C.LastName) AS LastName
                                    ,UPPER(RTRIM(C.DSIContId)) AS DSIContId
                                    ,UPPER(RTRIM(C.JobCode)) AS JobCd
                                    ,UPPER(RTRIM(C.Active)) AS Active
                                    ,UPPER(RTRIM(C.TestFlag)) AS TestFlag
                                    ,ISNULL(M.EmailAddress, C.EmailAddress) AS EmailAddress
                                    ,C.Created
                                    ,C.CreatedBy
                                    ,UPPER(RTRIM(ISNULL('M' + RTRIM(M.MasteruserID), 'C' + RTRIM(C.CustContNum)))) AS ContactGrp
                                FROM CONTACT.dbo.InCont C
                                LEFT JOIN CONTACT.dbo.InContMasterLink R ON R.CustContNum = C.CustContNum
                                LEFT JOIN CONTACT.dbo.InContMaster M ON M.MasterUserID = R.MasterUserID) alias
                                """
                            
        contact_dssi_core_df = read_sql_dsi(spark, config_dict, contact_dssi_core_query)
        contact_dsse_core_df = spark.table(contact_dse_tbl)
        contact_dsse_select_df = contact_dsse_core_df.select(col("ContactKey"),
                                                     col("DSContactID").alias("DSEContactID")).distinct()
        joined_df = contact_dssi_core_df.join(contact_dsse_select_df, contact_dssi_core_df.DSIContId == contact_dsse_select_df.ContactKey, 'left')
        final_df = joined_df.withColumn("DSContactID", coalesce(col("DSEContactID"), col("ContactGrp")))
        final_df = final_df.drop(col("ContactKey")).drop(col("DSEContactID"))
        renamed_df = final_df.withColumnRenamed("DSIContId", "DSSIDSEContactKey")

        inserted_count = delta_merge(spark, config_dict, "dssi_dim_contact_dssi", renamed_df, full_refresh)
        
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