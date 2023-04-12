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
        login_tels_query = """
                            (SELECT UPPER(RTRIM(f.FacilityPLT)) AS Location
									,UPPER(RTRIM(c.ContactKey)) AS ContactKey
									,cast(t.[When] AS DATE) AS [Date]
									,sum(LoginTELS) AS LoginTELS
								FROM (
									SELECT t.PersonID
										,t.LocationBusinessUnitID
										,t.[When]
										,1 AS LoginTELS
									FROM CONTACT.dbo.telsSignInActivity t
									) AS T
								INNER JOIN MDID_BTRIEVE.dbo.clcont c ON c.personid = t.personid
								INNER JOIN contact.dbo.telsFacility f ON f.BusinessUnitID = t.LocationBusinessUnitID
								WHERE [when] > dateadd(year, datediff(year, 0, getdate()) - 7, 0)
									AND EXISTS (
										SELECT *
										FROM FinProfit_DM.dbo.DimContactCurrent x
										WHERE x.SourceContactKey = c.ContactKey
										)
									AND EXISTS (
										SELECT *
										FROM FinProfit_DM.dbo.DimLocationCurrent x
										WHERE x.SourceLocationId = f.FacilityPLT
										)
								GROUP BY f.FacilityPLT
									,c.ContactKey
									,cast(t.[when] AS DATE)
                            ) login_tels_alias
                           """

        login_tels_df = read_sql_dse(spark, config_dict, login_tels_query)

        inserted_count = delta_merge(spark, config_dict, "dshe_fact_login_tels", login_tels_df, full_refresh)
        
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
