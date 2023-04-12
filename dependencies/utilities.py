from pyspark.sql import SparkSession, DataFrame
from pyspark.sql.types import StructType, StructField, StringType, LongType, FloatType
from pyspark.sql.functions import *
import traceback
from typing import Dict, Tuple
import boto3
import os   
import subprocess
import json


def get_db_utils(spark: SparkSession):
    dbutils = None
    if spark.conf.get("spark.databricks.service.clientenabled", None) == "true":
        print("Inside if")
        from pyspark.dbutils import DBUtils
        dbutils = DBUtils(spark)
    else:
        import IPython
        dbutils = IPython.get_ipython().user_ns["dbutils"]
    return dbutils


def connection(jdbcHostname, jdbcDatabase, jdbcPort, username, password):
    jdbcUrl = "jdbc:sqlserver://{0}:{1};database={2}".format(
        jdbcHostname, jdbcPort, jdbcDatabase)
    connectionProperties = {
        "user": username,
        "password": password,
        "driver": "com.microsoft.sqlserver.jdbc.SQLServerDriver"
    }
    return [jdbcUrl, connectionProperties]


def read_sql_dse(spark: SparkSession, config: Dict, query: str, db_name: str = None):
    jdbcHostname = config["dse_jdbcHostname"]
    jdbcDatabase = config["dse_jdbcDatabase"]
    server = config["dse_server_name"]
    jdbcPort = config["dse_jdbcPort"]
    env = config["env"]
    vault_init(env)
    token = get_vault_token(env)

    try:
        creds = get_database_credentials(env, server, token)
        username = creds[0]
        password = creds[1]
        conn = connection(jdbcHostname, jdbcDatabase, jdbcPort, username, password) if db_name is None or db_name.strip(
        ) == "" else connection(jdbcHostname, db_name, jdbcPort, username, password)
        jdbc = conn[0]
        conntprop = conn[1]
        df = spark.read.jdbc(url=jdbc, table=query, properties=conntprop).cache()
    except Exception:
        print(traceback.format_exc())
    else:
        return df


def read_sql_dsi(spark: SparkSession, config: Dict, query: str, db_name: str = None):
    jdbcHostname = config["dsi_jdbcHostname"]
    jdbcDatabase = config["dsi_jdbcDatabase"]
    server = config["dsi_server_name"]
    jdbcPort = config["dsi_jdbcPort"]
    env = config["env"]
    vault_init(env)
    token = get_vault_token(env)

    try:
        creds = get_database_credentials(env, server, token)
        username = creds[0]
        password = creds[1]
        conn = connection(jdbcHostname, jdbcDatabase, jdbcPort, username, password) if db_name is None or db_name.strip(
        ) == "" else connection(jdbcHostname, db_name, jdbcPort, username, password)
        jdbc = conn[0]
        conntprop = conn[1]
        df = spark.read.jdbc(url=jdbc, table=query, properties=conntprop).cache()
    except Exception:
        print(traceback.format_exc())
    else:
        return df

def read_rds_dsi(spark: SparkSession, config: Dict, query: str):
    rds_driver = config["dsi_rds_driver"]
    rds_url = config["dsi_rds_url"]
    SECRET = config["vault_dssi_rds_path"]
    env = config["env"]
    vault_init(env)
    token = get_vault_token(env)

    try:
        user_key = config["vault_rds_user_key"]
        username = read_vault_secret(env, SECRET, user_key, token)
        pswd_key = config["vault_rds_pswd_key"]
        password = password = read_vault_secret(env, SECRET, pswd_key, token)
        df = spark.read \
        .format("jdbc") \
        .option("driver", rds_driver) \
        .option("url", rds_url) \
        .option("user", username).option("password", password) \
        .option("query", query) \
        .load()
    except Exception:
        print(traceback.format_exc())
    else:
        return df


def get_sys_exception():
    exc_type, exc_value, exc_traceback = sys.exc_info()
    trace_back = traceback.extract_tb(exc_traceback)
    stack_trace = list()

    for trace in trace_back:
        stack_trace.append(
            f"File: {trace[0]}, Line: {trace[1]}, Func.Name: {trace[2]}, Message: {trace[3]}")
    exc_type = exc_type.__name__
    exc_msg = str(exc_value).split(':')[0].strip()
    stack_trace_str = ' | '.join(stack_trace)
    return exc_type, exc_msg, stack_trace_str


def get_last_delta_operation_metrics(spark, table_name):
    sql_string = f"""
                    SELECT operationMetrics
                    FROM (
                        SELECT *
                               , RANK() OVER (ORDER BY A.version DESC) AS rank
                        FROM 
                        (DESCRIBE HISTORY {table_name}) A)
                        WHERE rank = 1;
                 """
    df = spark.sql(sql_string)
    return df.collect()[0][0]


def log_run_metrics(spark: SparkSession, config: Dict, module: str, sub_module: str, job: str, status: str, records_written: int, elapsed_time: float, trigger_time: str, exc_type: str, exc_msg: str, stack_trace: str) -> None:
    try:
        table = config["logs"]['table'].strip().lower()
        path = config["logs"]['path'].strip().lower()
        format = config["logs"]['format'].strip().lower()

        app_id = str(spark.conf.get('spark.app.id'))
        rows = [(app_id, module, sub_module, job, status, records_written,
                 elapsed_time, trigger_time, exc_type, exc_msg, stack_trace)]
        schema = StructType([
            StructField("app_id", StringType(), True),
            StructField('module', StringType(), True),
            StructField('sub_module', StringType(), True),
            StructField("job", StringType(), True),
            StructField("status", StringType(), True),
            StructField("records_written", LongType(), True),
            StructField("elapsed_time_s", FloatType(), True),
            StructField("trigger_time", StringType(), True),
            StructField("exc_type", StringType(), True),
            StructField("exc_msg", StringType(), True),
            StructField("stack_trace", StringType(), True),
        ])
        df = spark.createDataFrame(rows, schema)
        final_df = df.withColumn('records_written', col('records_written').cast('long')) \
            .withColumn('elapsed_time_s', col('elapsed_time_s').cast('float')) \
            .withColumn('trigger_time', to_timestamp('trigger_time'))
        final_df.write \
            .format(format) \
            .mode('append') \
            .option('path', path) \
            .saveAsTable(table)

    except Exception:
        print(f"{'/-'*10} Exception in Logging {'/-'*10}")
        print(traceback.format_exc())


def duplicate_check(df: DataFrame, keys: list) -> DataFrame:
    """
    Return duplicates in a given df based on certain columns
    :param df: Dataframe to be check for null
    :type df: Dataframe
    :param cols: List of grouping cols
    :type cols: list
    :rtype: int
    """
    return df.groupBy(keys).count().filter("count > 1")


def null_check(df: DataFrame, cols: list) -> DataFrame:
    """
    Count null values in given columns list
    :param df: Dataframe to be check for null
    :type df: Dataframe
    :param cols: List of columns to be null checked
    :type cols: list
    :rtype: int
    """
    # select_df = df.select(cols)
    # select_df = select_df.select(
    #     [when(trim(lower(col(c))).isin(["", "null"]) == True, None).otherwise(
    #         col(c)).alias(c) for c in select_df.columns]
    # )
    # non_null_df = spark.createDataFrame([], StructType([]))
    # null_df = spark.createDataFrame([], StructType([]))
    # for c in cols:
    #     non_null_df = select_df.filter(col(c).isNotNull())
    #     null_df = select_df.filter(col(c).isNull())

    null_df = df.filter(" OR ".join(map(lambda c: c + " IS NULL", cols)))
    return null_df


def delta_merge(spark: SparkSession, config_dict: Dict, table_key: str, result_df: DataFrame, full_refresh: int = 0) -> int:
    tableName = config_dict[table_key]['table'].strip()
    tablePath = config_dict[table_key]['path'].strip()
    targetType = config_dict[table_key]['format'].strip().lower()


    print(f"Table Name: {tableName}")
    print(f"Table Path: {tablePath}")
    print(f"Target Type: {targetType}")

    # Delta Merge - Low Shuffle Config
    merge_key = config_dict[table_key]['pk'].strip().split(';')
    print(f"Merge Keys: {', '.join(merge_key)}")
    dup_df = duplicate_check(result_df, merge_key)
    dup_count = dup_df.count()
    null_df = null_check(result_df, merge_key)
    null_count = null_df.count()

    # Data Quality Check
    if dup_count != 0:
        dup_df.show(100)
        print(f"ERROR! - Duplicate records found (first 100 shown). Cannot merge the dataframe")
        raise Exception(
            f"ERROR! - Duplicate records found. Cannot merge the dataframe")
    elif null_count != 0:
        print(f"ERROR! - Null values found in merge keys (first 100 shown). Cannot merge the dataframe")
        null_df.show(100)
        raise Exception(
            f"ERROR! - Null values found in merge keys. Cannot merge the dataframe")
    else:
        if full_refresh == 1:
            print(f"{'/-'*10} Full Refresh {'/-'*10}")
            result_df.write.format(targetType).mode("overwrite").option("mergeSchema", True).option('path', tablePath).saveAsTable(tableName)
        else:
            print(f"{'/-'*10} Delta Merge {'/-'*10}")
            pk_comparision = ""

            for i in range(0, len(merge_key)):
                if i < len(merge_key) - 1:
                    pk_comparision = pk_comparision + "t." + \
                        merge_key[i] + " = s." + merge_key[i] + " AND "
                else:
                    pk_comparision = pk_comparision + "t." + \
                        merge_key[i] + " = s." + merge_key[i]

            print(f"{'/-'*10} Merge Condition: {pk_comparision} {'/-'*10}")

            from delta.tables import DeltaTable
            spark.conf.set("spark.databricks.delta.schema.autoMerge.enabled", True)
            spark.conf.set("spark.databricks.delta.merge.enableLowShuffle", True)

            print(f"{'/-'*5} Attempting to write data :{result_df.count()} records {'/-'*5}")
            result_df.show()
            result_df.limit(0).write.format(targetType).mode("append").option("mergeSchema", True).option('path', tablePath).saveAsTable(tableName)
            
            target_table = DeltaTable.forPath(spark, tablePath)
            print(f"{'/-'*10} Merging data to {tableName} {'/-'*10}")

            target_table.alias("t") \
                .merge(
                    result_df.alias("s"),
                    pk_comparision
            ) \
                .whenMatchedUpdateAll() \
                .whenNotMatchedInsertAll() \
                .execute()

        operation_metrics = get_last_delta_operation_metrics(spark, tableName)
        return int(operation_metrics['numOutputRows'])
    return 0


# Vault Integration

def get_vault_url(env):
    if(env == "production"):
        return "https://vault.us-east-1.management.directsupply.cloud"
    else:
        return f"https://vault.us-east-1.management.directsupply-{env}.cloud"

def vault_init(env):
    s3 = boto3.client('s3')
    bucket_name = f"ds-data-databricks-{env}"
    certificate_file_name = "certs/directsupply-enterprise-root-ca.crt"
    certificate = s3.get_object(Bucket=bucket_name, Key=certificate_file_name)['Body'].read().decode('utf-8')
    f = open("/usr/local/share/ca-certificates/directsupply-enterprise-root-ca.crt", "a")
    f.write(certificate)
    f.close()
    subprocess.check_output("sudo update-ca-certificates", shell=True)
    subprocess.run(["wget", "https://releases.hashicorp.com/vault/1.11.3/vault_1.11.3_linux_amd64.zip", "-O", "/tmp/vault.zip"])
    subprocess.run(["unzip", "/tmp/vault.zip", "-d", "/usr/bin"])
    os.environ["PATH"] += os.pathsep + "/usr/bin"
    os.environ["SSL_CERT_FILE"] = "/usr/local/share/ca-certificates/directsupply-enterprise-root-ca.crt"
    
def get_vault_token(env):
    AWS_PROFILE= "vault.management.directsupply.cloud"
    VAULT_ADDR = get_vault_url(env)
    AWS_ROLE = f"databricks-{env}-data-access"
    token_output = subprocess.run(["vault", "login", "-field=token", "-method=aws","header_value=vault.management.directsupply.cloud", f"role={AWS_ROLE}"], env={"VAULT_ADDR": VAULT_ADDR, "AWS_PROFILE": AWS_PROFILE, "VAULT_CONFIG_PATH": "/usr/bin/.vault", "PATH": os.environ["PATH"]}, capture_output=True, text=True)
    return token_output.stdout

def read_vault_secret(env, path, field, token):
    AWS_PROFILE= "vault.management.directsupply.cloud"
    VAULT_ADDR = get_vault_url(env)
    output = subprocess.run(["vault", "kv", "get", f"-field={field}", "-mount=secrets", path], env={"VAULT_ADDR": VAULT_ADDR, "AWS_PROFILE": AWS_PROFILE, "VAULT_CONFIG_PATH": "/usr/bin/.vault", "PATH": os.environ["PATH"], "VAULT_TOKEN": token}, capture_output=True, text=True)
    return output.stdout

def get_database_credentials(env, database, token):
    AWS_PROFILE= "vault.management.directsupply.cloud"
    VAULT_ADDR = get_vault_url(env)
    output = subprocess.run(["vault", "read", "-format=json", f"databases/creds/{database}-DSIAPP_DatabricksReplication"], env={"VAULT_ADDR": VAULT_ADDR, "AWS_PROFILE": AWS_PROFILE, "VAULT_CONFIG_PATH": "/usr/bin/.vault", "PATH": os.environ["PATH"], "VAULT_TOKEN": token}, capture_output=True, text=True)
    print(output.stderr)
    jsonOut = json.loads(output.stdout)
    return (jsonOut["data"]["username"], jsonOut["data"]["password"])