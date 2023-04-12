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
        product_dse_query = """
                        (SELECT p.ProductCurrentKey
                            ,p.SourceNonCatProdNbr AS ProductNbr
                            ,p.SegmentId AS ProductSegmentId
                            ,p.SegmentNm AS ProductSegment
                            ,p.ProgramId AS ProductProgramId
                            ,p.ProgramNm AS ProductProgram
                            ,UPPER(RTRIM(p.SubGroupCd)) AS ProductSubGroupId
                            ,p.SubGroupNm AS ProductSubGroup
                            ,p.PrcFamilyNm AS ProductPriceFamily
                            ,p.TypeNm AS ProductType
                            ,p.SubTypeNm AS ProductSubType
                            ,p.PreFlatSourceCatProdNbr AS ProductPreFlatNbr
                            ,P.ProductDesc
                            ,UPPER(RTRIM(p.SupplierCd)) AS SupplierCd
                            ,p.SupplierNm
                        FROM FinProfit_DM.dbo.DimProductCurrent p) alias
                          """

        product_dse_df = read_sql_dse(spark, config_dict, product_dse_query, "FinProfit_DM")

        inserted_count = delta_merge(spark, config_dict, "dshe_dim_product_dse", product_dse_df, full_refresh)
        
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
