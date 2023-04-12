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

        contact_query = """
                        (SELECT UPPER(RTRIM(C.ContactKey)) AS ContactKey
                            ,UPPER(RTRIM(C.BaseLocation)) AS BaseLocation
                            ,C.IsSlug
                            ,C.PreName
                            ,C.FirstName
                            ,C.MidName AS MiddleName
                            ,C.LastName
                            ,C.SufName AS Suffix
                            ,C.Salutation
                            ,C.JobCode AS JobCd
                            ,C.JobDescription AS JobCdDescription
                            ,C.PhoneAccess
                            ,C.PhoneAreaCode
                            ,C.Phone
                            ,C.PhoneExtension AS PhoneExt
                            ,C.DateCreated
                            ,C.DateUpdated
                            ,C.PersonID
                            ,ISNULL(E.EmailAddress, '') AS EmailAddress
                            ,'D' + UPPER(RTRIM(COALESCE(NULLIF(R2.ContactKey, ''), NULLIF(R1.ContactKey, ''), C.ContactKey))) AS DSContactID
                            ,C2.StatusDesc AS Status
                            ,C2.JobBucketCd
                            ,C2.JobBucketDesc AS JobBucket
                            ,C2.JobCdDesc AS JobTitle
                        FROM MDID_BTRIEVE.dbo.ClCont C
                        INNER JOIN FinProfit_DM.dbo.DimContactCurrent C2 ON c2.SourceContactKey = c.ContactKey
                        LEFT JOIN MDID_BTRIEVE.dbo.ClCont R1 ON R1.ContactKey = C.DupPointTo
                            AND C.DupPointTo > ''
                        LEFT JOIN MDID_BTRIEVE.dbo.ClCont R2 ON R2.ContactKey = R1.DupPointTo
                            AND R1.DupPointTo > ''
                        LEFT JOIN MDID_BTRIEVE.dbo.ClEmail E ON E.Location = ''
                            AND E.ContactKey = C.ContactKey
                            AND E.EmailCode = 'CE') alias
                        """

        contact_df = read_sql_dse(spark, config_dict, contact_query)
        print(f"{'/-'*5} Queried Data count: {contact_df.count()} {'/-'*5}")
        contact_df.show()
        inserted_count = delta_merge(spark, config_dict, "dshe_dim_contact_dse", contact_df, full_refresh)
        
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
