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
        fact_activity_smart_query = """
                SELECT upper(rtrim(l.sourcelocationid_plt)) AS Location
                    ,d.DATE AS DATE
                    ,sum(CASE 
                            WHEN w.activityname = 'Login'
                                THEN 1
                            ELSE 0
                            END) AS Logins
                    ,sum(CASE 
                            WHEN w.activityname = 'VitalsSubmission'
                                THEN 1
                            ELSE 0
                            END) AS Vitals
                FROM PUBLIC.fact_usage u
                INNER JOIN PUBLIC.dim_customer l ON l.dimcustomersk = u.dimcustomersk
                INNER JOIN PUBLIC.dim_date d ON d.dimdatesk = u.dimusagedatesk
                INNER JOIN PUBLIC.dim_workflow w ON w.dimworkflowsk = u.dimworkflowsk
                GROUP BY upper(rtrim(l.sourcelocationid_plt))
                    ,d.DATE
                """

        fact_activity_smart_df = read_rds_dsi(
            spark, config_dict, fact_activity_smart_query)

        fact_activity_smart_df = fact_activity_smart_df.withColumnRenamed("location", "Location") \
            .withColumnRenamed("logins", "LoginsDSSmart") \
            .withColumnRenamed("date", "Date") \
            .withColumnRenamed("vitals", "VitalsDSSmart")
        print(f"{'/-'*10} Renamed DF {'/-'*10}")
        fact_activity_smart_df.show()

        inserted_count = delta_merge(
            spark, config_dict, "dssi_fact_activity_dssmart", fact_activity_smart_df, full_refresh)

        print(f"{'/-'*40}")
        print(f"{'--'*40}")
    except Exception:
        end_time = time.time()
        elapsed_time = end_time - start_time
        exc_type, exc_msg, stack_trace = get_sys_exception()
        log_run_metrics(spark, config_dict, module, sub_module, job, "Failure", 0, elapsed_time, str(
            trigger_time), exc_type, exc_msg, stack_trace)
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
        log_run_metrics(spark, config_dict, module, sub_module, job, "Success",
                        inserted_count, elapsed_time, str(trigger_time), None, None, None)
        print(
            f"{module}.{sub_module}.{job} job ran successfully. Count = {inserted_count}")
    finally:
        print(
            f"Execution of {module}.{sub_module}.{job} job took {elapsed_time} seconds")
