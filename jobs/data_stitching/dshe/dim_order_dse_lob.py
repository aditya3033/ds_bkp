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
        order_lob_query = """
                            (
                            SELECT LobCurrentKey AS LineOfBusinessCurrentKey
                                ,b.LobCd
                                ,b.LobNm
                                ,b.LobGroupCd
                                ,b.LobGroupNm
                            FROM FinProfit_DM.dbo.DimLineOfBusinessCurrent b
                            ) order_lob_alias
                          """

        order_lob_df = read_sql_dse(spark, config_dict, order_lob_query)
        
        renamed_df = order_lob_df.withColumnRenamed("LobNm", "LOB") \
                                 .withColumnRenamed("LobCd", "LOBCd") \
                                 .withColumnRenamed("LobGroupCd", "LOBGroupCd") \
                                 .withColumnRenamed("LobGroupNm", "LOBGroup")

        inserted_count = delta_merge(spark, config_dict, "dshe_dim_order_dse_lob", renamed_df, full_refresh)
        
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
