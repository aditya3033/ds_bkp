import argparse
from typing import Dict, Tuple, Any
import json
from pyspark.sql import SparkSession
import importlib


def create_spark_session(job_name: str):
    """Create spark session to run the job

    :param job_name: job name
    :type job_name: str
    :return: spark and logger
    :rtype: Tuple[SparkSession,Log4j]
    """
    spark: SparkSession = (SparkSession.builder.
                           appName(job_name).
                           enableHiveSupport().
                           getOrCreate())
    app_id: str = spark.conf.get('spark.app.id')
    log4j = spark._jvm.org.apache.log4j
    message_prefix = '<' + job_name + ' ' + app_id + '>'
    logger = log4j.LogManager.getLogger(message_prefix)
    return spark, logger


def load_config_file(spark: SparkSession, file_path: str, env: str) -> Dict:
    """
    Reads the config json file from the dbfs location provided as job argument

    :param spark: spark session object
    :param file_path: path of the file
    :return: config dictionary
    """
    try:
        json_text = spark.read.format("text").option("wholetext", True).load(file_path).collect()[0][0]
        json_dict = json.loads(json_text)
        return json_dict[env]

    except FileNotFoundError:
        raise FileNotFoundError(f'{file_path} Not found')


def parse_job_args(job_args: str) -> Dict:
    """
    Reads the additional job_args and parse as a dictionary

    :param job_args: extra job_args i.e. k1=v1 k2=v2
    :return: config dictionary
    """
    return {a.split('=')[0]: a.split('=')[1] for a in job_args}


def main():
    parser = argparse.ArgumentParser(description='Job submitter',
                                     usage='''--job job_name,
                                     --conf-file config_file_name,
                                     --job-args k1=v1 k2=v2''')
    parser.add_argument('--module',
                        help='module name',
                        dest='module_name',
                        required=True)
    parser.add_argument('--sub-module',
                            help='sub module name',
                            dest='sub_module_name',
                            required=True)
    parser.add_argument('--job',
                        help='job name',
                        dest='job_name',
                        required=True)
    parser.add_argument('--conf-file',
                        help='Config file path',
                        dest='conf_file',
                        required=True)
    parser.add_argument('--job-args',
                        help='Dynamic job arguments',
                        required=False,
                        nargs='*')
    parser.add_argument('--env',
                        help='Environment',
                        required=True,
                        dest='env')
    parser.add_argument('--full-refresh',
                        help='Truncate & Load',
                        required=False,
                        dest='full_refresh')
    args = parser.parse_args()

    module_name = args.module_name
    sub_module_name = args.sub_module_name
    job_name = args.job_name
    env = args.env
    full_refresh = args.full_refresh

    spark, logger = create_spark_session(job_name)
    config_file = args.conf_file 
    config_dict: Dict = load_config_file(spark, config_file, env)
    if args.job_args:
        job_args = parse_job_args(args.job_args)
        config_dict.update(job_args)

    print(f'calling job {module_name}.{sub_module_name}.{job_name}  with config:')
    print(json.dumps(config_dict, indent=1))
    job = importlib.import_module(f'jobs.{module_name}.{sub_module_name}.{job_name}')
    job.run(spark, config_dict, module_name, sub_module_name, job_name, int(full_refresh.strip()))

if __name__ == '__main__':
    main()