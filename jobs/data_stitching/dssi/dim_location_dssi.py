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
        location_dse_tbl = config_dict["dshe_dim_location_dse"]["table"]
        location_dssi_core_query = """
       (
        SELECT UPPER(RTRIM(l.CustCode)) AS CustCode
        ,UPPER(RTRIM(l.CustLocNum)) AS CustLocNum
        ,f.FacilityKey
        ,UPPER(RTRIM(l.STATUS)) AS STATUS
        ,UPPER(RTRIM(NULLIF(l.DSILocNum, ''))) AS DSILocNum
        ,l.Name
        ,l.AddressLine1
        ,l.AddressLine2
        ,l.City
        ,l.STATE
        ,l.Zip
        ,l.PhoneAccess
        ,l.PhoneAreaCode
        ,l.Phone
        ,l.PhoneExt
        ,UPPER(RTRIM(l.KeepActive)) AS KeepActive
        ,l.LiveDate
        ,UPPER(RTRIM(l.LocnTestFlag)) AS LocnTestFlag
        ,CAST(UPPER(RTRIM(l.LocnType)) AS INT) AS LocnType
        ,CASE 
            WHEN l.Created BETWEEN '1/1/1985'
                    AND getdate()
                THEN l.Created
            END AS CreatedWhen
        ,f.BedSize AS TotalBedCnt
        FROM CONTACT.dbo.InLocn l
        INNER JOIN BI.dbo.DimFacility F ON F.CustCode = l.CustCode
            AND f.CustLocNum = l.CustLocNum
                ) dsi_core
        """
 
        location_dssi_core_df = read_sql_dsi(spark, config_dict, location_dssi_core_query)
        location_dssi_core_df = location_dssi_core_df.withColumn("DSSILocationID", concat(col("CustCode"), lit("."), col("CustLocNum")))
# UPDATEd WITH NEW DSHE NAME
        location_dsse_core_df = spark.table(location_dse_tbl)
        location_dsse_core_df = location_dsse_core_df.withColumn("DSLocationID", col("Location"))

        dse_select_df = location_dsse_core_df.select(col("Location").alias("DSELocationID")).distinct()
        joined_df = location_dssi_core_df.join(dse_select_df, location_dssi_core_df.DSILocNum == dse_select_df.DSELocationID, 'left')
        final_df = joined_df.withColumn("DSLocationID", coalesce(col("DSELocationID"), col("DSSILocationID")))
        final_df = final_df.drop(col("Location")).drop(col("DSELocationID")).drop(col("DSSILocationID"))
        renamed_df = final_df.withColumnRenamed("DSILocNum", "DSSIDSELocation") \
                            .withColumnRenamed("LocnTestFlag", "LocTestFlag") \
                            .withColumnRenamed("LocnType", "LocType") \
                            .withColumnRenamed("Name", "DSSILocName") \
                            .withColumnRenamed("CreatedWhen", "CreatedDate")

        print(f"{'/-'*10} Renamed DF {'/-'*10}")
        renamed_df.show()

        inserted_count = delta_merge(spark, config_dict, "dssi_dim_location_dssi", renamed_df, full_refresh)
        
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