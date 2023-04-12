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
        order_channel_query = """(SELECT DISTINCT l.OrderChannelCd
                                ,l.OrderChannelDesc
                                ,l.OrderChannelGroupDesc
                                ,l.OrderChannelSubGroupDesc
                            FROM FinProfit_DM.dbo.factline l
                            WHERE l.OrderChannelCd NOT IN (
                                    'A'
                                    ,'C'
                                    ,'M'
                                    ,'O'
                                    )
                                    ) order_alias
                                """

        order_channel_df = read_sql_dse(spark, config_dict, order_channel_query, "FinProfit_DM")
        # renamed_df = order_channel_df.withColumnRenamed("OrderChannelCd", "OrdChannelCd") \
        #                              .withColumnRenamed("OrderChannelDesc", "OrdChannel") \
        #                              .withColumnRenamed("OrderChannelGroupDesc", "OrdChannelGrp") \
        #                              .withColumnRenamed("OrderChannelSubGroupDesc", "OrdChannelSubGrp")

        print(f"{'/-'*5} Queried Data count: {order_channel_df.count()} {'/-'*5}")
        order_channel_df.show()
        inserted_count = delta_merge(spark, config_dict, "dshe_dim_order_dse_channel", order_channel_df, full_refresh)
        
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