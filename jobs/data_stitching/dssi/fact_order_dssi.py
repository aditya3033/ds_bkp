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
        fact_order_dssi_core_query = """(
            SELECT UPPER(RTRIM(f.CustCode)) AS CustCode
                ,UPPER(RTRIM(f.CustLocNum)) AS CustLocNum
                ,f.FacilityKey
                ,c.CustContNum
                ,l.PODateKey AS DATE --key fields
                ,cast(CASE 
                        WHEN ls.Code in ('O', 'I') AND ps.StatusCode in ('F', 'O', 'P')
                            THEN 0
                        ELSE 1
                        END AS BIT) AS POCancelled
                ,UPPER(RTRIM(l.ChPONum)) AS PONbr
                ,UPPER(RTRIM(l.LineChPoNum)) AS LinePoNbr
                ,l.AccLineNum AS LineNbr
                ,l.Quantity AS LineQty
                ,l.UnitAmount AS LineUnitSell
                ,l.ExtendedAmount AS LineAmount
                ,UPPER(RTRIM(u.UMCode)) AS LineUMCd
                ,p.SuppProdNum AS ProductNbr
                ,isnull(nullif(l.ProductDesc, ''), p.ProductDesc) AS ProductDesc
                ,UPPER(RTRIM(p.ChSupplier)) AS SupplierCd
                ,p.SupplierName AS SupplierName
                ,UPPER(RTRIM(p.ParentChSupplier)) AS ParentSupplierCd
                ,p.ParentSupplierName AS ParentSupplierName
            FROM dbo.FactPOLine l
            INNER JOIN dbo.DimPOLineStatus ls ON ls.POLineStatusKey = l.POLineStatusKey
            INNER JOIN dbo.DimFacility f ON f.FacilityKey = l.FacilityKey
            INNER JOIN dbo.DimContact c ON c.ContactKey = l.OrderedByKey
            INNER JOIN dbo.DimCustomerProduct p ON p.CustomerProductKey = l.CustomerProductKey
            INNER JOIN dbo.DimUnitMeasure u ON u.UnitMeasureKey = l.UnitMeasureKey
            INNER JOIN dbo.DimPOStatus ps on ps.POStatusKey = l.POStatusKey
            WHERE l.PODateKey > dateadd(year, datediff(year, 0, getdate()) - 7, 0)
        ) alias"""
        
        fact_order_dssi_core_df = read_sql_dsi(spark, config_dict, fact_order_dssi_core_query)
    
        print(f"{'/-'*10} Renamed DF {'/-'*10}")
        fact_order_dssi_core_df.show()

        inserted_count = delta_merge(spark, config_dict, "dssi_fact_order_dssi", fact_order_dssi_core_df, full_refresh)
        
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