from pyspark.sql import SparkSession
from pyspark.sql.window import Window
from pyspark.sql.functions import *
from datetime import datetime
import time

from dependencies.utilities import *



def run(spark: SparkSession, config_dict: dict, module: str, sub_module: str, job: str, full_refresh: int = 0):
    print(f"{'/-'*10} Running {module}.{sub_module}.{job} {'/-'*10}")
    trigger_time = datetime.now()
    start_time = time.time()
    try:
        date_query = """
                    (SELECT DateKey AS Date
                        ,BusinessDayOfMonthNbr AS BusDay#OfMo
                        ,BusinessDayOfQuarterNbr AS BusDay#OfQtr
                        ,BusinessDayOfYearNbr AS BusDay#OfYear
                        ,IsStartOfMonth AS IsBOM
                        ,IsEndOfMonth AS IsEOM
                        ,IsHoliday
                        ,IsBudgetException 
                        ,StartOfMonthDate AS BegOfMonthDate
                        ,EndOfMonthDate 
                        ,BusinessStartOfMonthDate AS BusBegOfMonthDate
                        ,BusinessEndOfMonthDate AS BusEndOfMonthDate 
                        ,DayOfWeekNbr AS Day#ofWeek
                        ,DayOfMonthNbr AS Day#ofMo
                        ,DayOfYearNbr AS Day#ofYear
                        ,WeekOfYearNbr AS Week#
                        ,MonthOfYearNbr AS Month#
                        ,QuarterOfYearNbr AS Quarter#
                        ,Year 
                        ,DayName AS Weekday
                        ,MonthName AS Month
                        ,IsBusinessDay = CASE 
                            WHEN IsHoliday = 'N'
                                AND DayOfWeekNbr BETWEEN 2
                                    AND 6
                                THEN 'Y'
                            ELSE 'N'
                            END
                    FROM dbo.DimDate) alias
                    """
        
        print(f"{'/-'*10} Running the query {'/-'*10}")
        date_df = read_sql_dsi(spark, config_dict, date_query)
        print(f"{'/-'*10} DF {'/-'*10}")
        date_df.show()

        inserted_count = delta_merge(spark, config_dict, "dssi_dim_date", date_df, full_refresh)
        
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