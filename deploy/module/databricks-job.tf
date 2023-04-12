# 0. Job Workflow
resource "databricks_job" "job0" {
  name = "DataStitching_Job_Workflow"

  max_concurrent_runs = 2
  timeout_seconds = 21600

  # 1
  # change
  task{
    task_key = "DataStitching_DSHE_Dim_Order_Dse_Channel"

    library {
      whl = "s3://ds-data-databricks-${var.environment}/artifacts/DirectSupply-0.0.0-py3-none-any.whl"
    }
    new_cluster {
      num_workers   = 1
      spark_version = data.databricks_spark_version.latest.id
      node_type_id  = data.databricks_node_type.smallest.id
      data_security_mode = "SINGLE_USER"
      aws_attributes {
        instance_profile_arn = data.aws_iam_instance_profile.profile.arn
      }
      spark_env_vars = {
        "ENV" : "${var.environment}"
        "ROLE" : "databricks-${var.environment}-data-access"
        "BUCKET" : "ds-data-databricks-${var.environment}"
      }
      custom_tags = {
        "OwnerEmail":"datanomads@directsupply.com"
        "Application":"databricks"
        "Customer":"Direct Supply"
        "LineOfBusiness":"CIS"
        "Role":"cluster"
        "Environment":"${var.environment}"
        "Lifespan":"permanent"
      }
    }
    python_wheel_task {
      entry_point = "main_task"
      package_name = "DirectSupply"
      parameters =  [
                          "--module",
                          "data_stitching",
                          "--sub-module",
                          "dshe",
                          "--job",
                          "dim_order_dse_channel",
                          "--conf-file",
                          "s3://ds-data-databricks-${var.environment}/configs/config.json",
                          "--env",
                          "${var.environment}",
                          "--full-refresh",
                          "1"
                      ]
    }
  }


  # 2
  # change
  task{
    task_key = "DataStitching_DSHE_Dim_Order_Dse_Lob"
    depends_on {
      task_key = "DataStitching_DSHE_Dim_Order_Dse_Channel"
    }
    library {
      whl = "s3://ds-data-databricks-${var.environment}/artifacts/DirectSupply-0.0.0-py3-none-any.whl"
    }
    new_cluster {
      num_workers   = 1
      spark_version = data.databricks_spark_version.latest.id
      node_type_id  = data.databricks_node_type.smallest.id
      data_security_mode = "SINGLE_USER"
      aws_attributes {
        instance_profile_arn = data.aws_iam_instance_profile.profile.arn
      }
      spark_env_vars = {
        "ENV" : "${var.environment}"
        "ROLE" : "databricks-${var.environment}-data-access"
        "BUCKET" : "ds-data-databricks-${var.environment}"
      }
      custom_tags = {
        "OwnerEmail":"datanomads@directsupply.com"
        "Application":"databricks"
        "Customer":"Direct Supply"
        "LineOfBusiness":"CIS"
        "Role":"cluster"
        "Environment":"${var.environment}"
        "Lifespan":"permanent"
      }
    }
    python_wheel_task {
      entry_point = "main_task"
      package_name = "DirectSupply"
      parameters =  [
                          "--module",
                          "data_stitching",
                          "--sub-module",
                          "dshe",
                          "--job",
                          "dim_order_dse_lob",
                          "--conf-file",
                          "s3://ds-data-databricks-${var.environment}/configs/config.json",
                          "--env",
                          "${var.environment}",
                          "--full-refresh",
                          "1"
                      ]
    }
  }

  # 3
  # addition
  task{
    task_key = "DataStitching_DSHE_Dim_Product_Dse"
    depends_on {
      task_key = "DataStitching_DSHE_Dim_Order_Dse_Lob"
    }
    library {
      whl = "s3://ds-data-databricks-${var.environment}/artifacts/DirectSupply-0.0.0-py3-none-any.whl"
    }
    new_cluster {
      num_workers   = 1
      spark_version = data.databricks_spark_version.latest.id
      node_type_id  = data.databricks_node_type.smallest.id
      data_security_mode = "SINGLE_USER"
      aws_attributes {
        instance_profile_arn = data.aws_iam_instance_profile.profile.arn
      }
      spark_env_vars = {
        "ENV" : "${var.environment}"
        "ROLE" : "databricks-${var.environment}-data-access"
        "BUCKET" : "ds-data-databricks-${var.environment}"
      }
      custom_tags = {
        "OwnerEmail":"datanomads@directsupply.com"
        "Application":"databricks"
        "Customer":"Direct Supply"
        "LineOfBusiness":"CIS"
        "Role":"cluster"
        "Environment":"${var.environment}"
        "Lifespan":"permanent"
      }
    }
    python_wheel_task {
      entry_point = "main_task"
      package_name = "DirectSupply"
      parameters =  [
                          "--module",
                          "data_stitching",
                          "--sub-module",
                          "dshe",
                          "--job",
                          "dim_product_dse",
                          "--conf-file",
                          "s3://ds-data-databricks-${var.environment}/configs/config.json",
                          "--env",
                          "${var.environment}",
                          "--full-refresh",
                          "1"
                      ]
    }
  }

  # 4
  # change
  task{
    task_key = "DataStitching_DSHE_Fact_Order_Dse"
    depends_on {
      task_key = "DataStitching_DSHE_Dim_Product_Dse"
    }
    library {
      whl = "s3://ds-data-databricks-${var.environment}/artifacts/DirectSupply-0.0.0-py3-none-any.whl"
    }
    new_cluster {
      num_workers   = 2
      spark_version = data.databricks_spark_version.latest.id
      node_type_id  = data.databricks_node_type.smallest.id
      data_security_mode = "SINGLE_USER"
      aws_attributes {
        instance_profile_arn = data.aws_iam_instance_profile.profile.arn
      }
      spark_env_vars = {
        "ENV" : "${var.environment}"
        "ROLE" : "databricks-${var.environment}-data-access"
        "BUCKET" : "ds-data-databricks-${var.environment}"
      }
      custom_tags = {
        "OwnerEmail":"datanomads@directsupply.com"
        "Application":"databricks"
        "Customer":"Direct Supply"
        "LineOfBusiness":"CIS"
        "Role":"cluster"
        "Environment":"${var.environment}"
        "Lifespan":"permanent"
      }
    }
    python_wheel_task {
      entry_point = "main_task"
      package_name = "DirectSupply"
      parameters =  [
                          "--module",
                          "data_stitching",
                          "--sub-module",
                          "dshe",
                          "--job",
                          "fact_order_dse",
                          "--conf-file",
                          "s3://ds-data-databricks-${var.environment}/configs/config.json",
                          "--env",
                          "${var.environment}",
                          "--full-refresh",
                          "1"
                      ]
    }
  }

  # 5
  task{
    task_key = "DataStitching_DSHE_Fact_Login_Tels"
    depends_on {
      task_key = "DataStitching_DSHE_Fact_Order_Dse"
    }
    library {
      whl = "s3://ds-data-databricks-${var.environment}/artifacts/DirectSupply-0.0.0-py3-none-any.whl"
    }
    new_cluster {
      num_workers   = 2
      spark_version = data.databricks_spark_version.latest.id
      node_type_id  = data.databricks_node_type.smallest.id
      data_security_mode = "SINGLE_USER"
      aws_attributes {
        instance_profile_arn = data.aws_iam_instance_profile.profile.arn
      }
      spark_env_vars = {
        "ENV" : "${var.environment}"
        "ROLE" : "databricks-${var.environment}-data-access"
        "BUCKET" : "ds-data-databricks-${var.environment}"
      }
      custom_tags = {
        "OwnerEmail":"datanomads@directsupply.com"
        "Application":"databricks"
        "Customer":"Direct Supply"
        "LineOfBusiness":"CIS"
        "Role":"cluster"
        "Environment":"${var.environment}"
        "Lifespan":"permanent"
      }
    }
    python_wheel_task {
      entry_point = "main_task"
      package_name = "DirectSupply"
      parameters =  [
                          "--module",
                          "data_stitching",
                          "--sub-module",
                          "dshe",
                          "--job",
                          "fact_login_tels",
                          "--conf-file",
                          "s3://ds-data-databricks-${var.environment}/configs/config.json",
                          "--env",
                          "${var.environment}",
                          "--full-refresh",
                          "1"
                      ]
    }
  }

  # 6
  task{
    task_key = "DataStitching_DSHE_Dim_Location_Dse"
    depends_on {
      task_key = "DataStitching_DSHE_Fact_Login_Tels"
    }
    library {
      whl = "s3://ds-data-databricks-${var.environment}/artifacts/DirectSupply-0.0.0-py3-none-any.whl"
    }
    new_cluster {
      num_workers   = 1
      spark_version = data.databricks_spark_version.latest.id
      node_type_id  = data.databricks_node_type.smallest.id
      data_security_mode = "SINGLE_USER"
      aws_attributes {
        instance_profile_arn = data.aws_iam_instance_profile.profile.arn
      }
      spark_env_vars = {
        "ENV" : "${var.environment}"
        "ROLE" : "databricks-${var.environment}-data-access"
        "BUCKET" : "ds-data-databricks-${var.environment}"
      }
      custom_tags = {
        "OwnerEmail":"datanomads@directsupply.com"
        "Application":"databricks"
        "Customer":"Direct Supply"
        "LineOfBusiness":"CIS"
        "Role":"cluster"
        "Environment":"${var.environment}"
        "Lifespan":"permanent"
      }
    }
    python_wheel_task {
      entry_point = "main_task"
      package_name = "DirectSupply"
      parameters =  [
                          "--module",
                          "data_stitching",
                          "--sub-module",
                          "dshe",
                          "--job",
                          "dim_location_dse",
                          "--conf-file",
                          "s3://ds-data-databricks-${var.environment}/configs/config.json",
                          "--env",
                          "${var.environment}",
                          "--full-refresh",
                          "1"
                      ]
    }
  }

    # 7
  task{
    task_key = "DataStitching_DSHE_Dim_Contact_Dse"
    depends_on {
      task_key = "DataStitching_DSHE_Dim_Location_Dse"
    }
    library {
      whl = "s3://ds-data-databricks-${var.environment}/artifacts/DirectSupply-0.0.0-py3-none-any.whl"
    }
    new_cluster {
      num_workers   = 1
      spark_version = data.databricks_spark_version.latest.id
      node_type_id  = data.databricks_node_type.smallest.id
      data_security_mode = "SINGLE_USER"
      aws_attributes {
        instance_profile_arn = data.aws_iam_instance_profile.profile.arn
      }
      spark_env_vars = {
        "ENV" : "${var.environment}"
        "ROLE" : "databricks-${var.environment}-data-access"
        "BUCKET" : "ds-data-databricks-${var.environment}"
      }
      custom_tags = {
        "OwnerEmail":"datanomads@directsupply.com"
        "Application":"databricks"
        "Customer":"Direct Supply"
        "LineOfBusiness":"CIS"
        "Role":"cluster"
        "Environment":"${var.environment}"
        "Lifespan":"permanent"
      }
    }
    python_wheel_task {
      entry_point = "main_task"
      package_name = "DirectSupply"
      parameters =  [
                          "--module",
                          "data_stitching",
                          "--sub-module",
                          "dshe",
                          "--job",
                          "dim_contact_dse",
                          "--conf-file",
                          "s3://ds-data-databricks-${var.environment}/configs/config.json",
                          "--env",
                          "${var.environment}",
                          "--full-refresh",
                          "1"
                      ]
    }
  }


  # 8
  task{
    task_key = "DataStitching_DSSI_Dim_Date"
    
    depends_on {
      task_key = "DataStitching_DSHE_Dim_Contact_Dse"
    }
    library {
      whl = "s3://ds-data-databricks-${var.environment}/artifacts/DirectSupply-0.0.0-py3-none-any.whl"
    }
    new_cluster {
      num_workers   = 1
      spark_version = data.databricks_spark_version.latest.id
      node_type_id  = data.databricks_node_type.smallest.id
      data_security_mode = "SINGLE_USER"
      aws_attributes {
        instance_profile_arn = data.aws_iam_instance_profile.profile.arn
      }
      spark_env_vars = {
        "ENV" : "${var.environment}"
        "ROLE" : "databricks-${var.environment}-data-access"
        "BUCKET" : "ds-data-databricks-${var.environment}"
      }
      custom_tags = {
        "OwnerEmail":"datanomads@directsupply.com"
        "Application":"databricks"
        "Customer":"Direct Supply"
        "LineOfBusiness":"CIS"
        "Role":"cluster"
        "Environment":"${var.environment}"
        "Lifespan":"permanent"
      }

    }
    python_wheel_task {
      entry_point = "main_task"
      package_name = "DirectSupply"
      parameters =  [
                          "--module",
                          "data_stitching",
                          "--sub-module",
                          "dssi",
                          "--job",
                          "dim_date",
                          "--conf-file",
                          "s3://ds-data-databricks-${var.environment}/configs/config.json",
                          "--env",
                          "${var.environment}",
                          "--full-refresh",
                          "1"
                      ]
    }
  }
  
  # 9
  task{
    task_key = "DataStitching_DSSI_Dim_Contact"
    depends_on {
      task_key = "DataStitching_DSSI_Dim_Date"
    }
    library {
      whl = "s3://ds-data-databricks-${var.environment}/artifacts/DirectSupply-0.0.0-py3-none-any.whl"
    }
    new_cluster {
      num_workers   = 1
      spark_version = data.databricks_spark_version.latest.id
      node_type_id  = data.databricks_node_type.smallest.id
      data_security_mode = "SINGLE_USER"
      aws_attributes {
        instance_profile_arn = data.aws_iam_instance_profile.profile.arn
      }
      spark_env_vars = {
        "ENV" : "${var.environment}"
        "ROLE" : "databricks-${var.environment}-data-access"
        "BUCKET" : "ds-data-databricks-${var.environment}"
      }
      custom_tags = {
        "OwnerEmail":"datanomads@directsupply.com"
        "Application":"databricks"
        "Customer":"Direct Supply"
        "LineOfBusiness":"CIS"
        "Role":"cluster"
        "Environment":"${var.environment}"
        "Lifespan":"permanent"
      }

    
    }
    python_wheel_task {
      entry_point = "main_task"
      package_name = "DirectSupply"
      parameters =  [
                          "--module",
                          "data_stitching",
                          "--sub-module",
                          "dssi",
                          "--job",
                          "dim_contact_dssi",
                          "--conf-file",
                          "s3://ds-data-databricks-${var.environment}/configs/config.json",
                          "--env",
                          "${var.environment}",
                          "--full-refresh",
                          "1"
                      ]
    }
  }

  # 10
  task{
    task_key = "DataStitching_DSSI_Dim_Location"
    depends_on {
      task_key = "DataStitching_DSSI_Dim_Contact"
    }
    library {
      whl = "s3://ds-data-databricks-${var.environment}/artifacts/DirectSupply-0.0.0-py3-none-any.whl"
    }
    new_cluster {
      num_workers   = 1
      spark_version = data.databricks_spark_version.latest.id
      node_type_id  = data.databricks_node_type.smallest.id
      data_security_mode = "SINGLE_USER"
      aws_attributes {
        instance_profile_arn = data.aws_iam_instance_profile.profile.arn
      }
      spark_env_vars = {
        "ENV" : "${var.environment}"
        "ROLE" : "databricks-${var.environment}-data-access"
        "BUCKET" : "ds-data-databricks-${var.environment}"
      }
      custom_tags = {
        "OwnerEmail":"datanomads@directsupply.com"
        "Application":"databricks"
        "Customer":"Direct Supply"
        "LineOfBusiness":"CIS"
        "Role":"cluster"
        "Environment":"${var.environment}"
        "Lifespan":"permanent"
      }
    }
    python_wheel_task {
      entry_point = "main_task"
      package_name = "DirectSupply"
      parameters =  [
                          "--module",
                          "data_stitching",
                          "--sub-module",
                          "dssi",
                          "--job",
                          "dim_location_dssi",
                          "--conf-file",
                          "s3://ds-data-databricks-${var.environment}/configs/config.json",
                          "--env",
                          "${var.environment}",
                          "--full-refresh",
                          "1"
                      ]
    }
  } 

  # 11
  task{
    task_key = "DataStitching_DSSI_Fact_Order"
    depends_on {
      task_key = "DataStitching_DSSI_Dim_Location"
    }
    library {
      whl = "s3://ds-data-databricks-${var.environment}/artifacts/DirectSupply-0.0.0-py3-none-any.whl"
    }
    new_cluster {
      num_workers   = 2
      spark_version = data.databricks_spark_version.latest.id
      node_type_id  = data.databricks_node_type.smallest.id
      data_security_mode = "SINGLE_USER"
      aws_attributes {
        instance_profile_arn = data.aws_iam_instance_profile.profile.arn
      }
      spark_env_vars = {
        "ENV" : "${var.environment}"
        "ROLE" : "databricks-${var.environment}-data-access"
        "BUCKET" : "ds-data-databricks-${var.environment}"
      }
      custom_tags = {
        "OwnerEmail":"datanomads@directsupply.com"
        "Application":"databricks"
        "Customer":"Direct Supply"
        "LineOfBusiness":"CIS"
        "Role":"cluster"
        "Environment":"${var.environment}"
        "Lifespan":"permanent"
      }
    }
    python_wheel_task {
      entry_point = "main_task"
      package_name = "DirectSupply"
      parameters =  [
                          "--module",
                          "data_stitching",
                          "--sub-module",
                          "dssi",
                          "--job",
                          "fact_order_dssi",
                          "--conf-file",
                          "s3://ds-data-databricks-${var.environment}/configs/config.json",
                          "--env",
                          "${var.environment}",
                          "--full-refresh",
                          "1"
                      ]
    }
  }

  # 12
  task{
    task_key = "DataStitching_DSSI_Fact_Activity_DSSmart"
    depends_on {
      task_key = "DataStitching_DSSI_Fact_Order"
    }
    library {
      whl = "s3://ds-data-databricks-${var.environment}/artifacts/DirectSupply-0.0.0-py3-none-any.whl"
    }
    library {
      jar = "s3://ds-data-databricks-${var.environment}/libraries/redshift-jdbc42-2.1.0.10.jar"
    }
    new_cluster {
      num_workers   = 1
      spark_version = data.databricks_spark_version.latest.id
      node_type_id  = data.databricks_node_type.smallest.id
      data_security_mode = "SINGLE_USER"
      aws_attributes {
        instance_profile_arn = data.aws_iam_instance_profile.profile.arn
      }
      spark_env_vars = {
        "ENV" : "${var.environment}"
        "ROLE" : "databricks-${var.environment}-data-access"
        "BUCKET" : "ds-data-databricks-${var.environment}"
      }
      custom_tags = {
        "OwnerEmail":"datanomads@directsupply.com"
        "Application":"databricks"
        "Customer":"Direct Supply"
        "LineOfBusiness":"CIS"
        "Role":"cluster"
        "Environment":"${var.environment}"
        "Lifespan":"permanent"
      }
    }
    python_wheel_task {
      entry_point = "main_task"
      package_name = "DirectSupply"
      parameters =  [
                          "--module",
                          "data_stitching",
                          "--sub-module",
                          "dssi",
                          "--job",
                          "fact_activity_dssmart",
                          "--conf-file",
                          "s3://ds-data-databricks-${var.environment}/configs/config.json",
                          "--env",
                          "${var.environment}",
                          "--full-refresh",
                          "1"
                      ]
    }
  }

  # 13
  task{
    task_key = "DataStitching_DSSI_Dim_Location_DS"
    depends_on {
      task_key = "DataStitching_DSSI_Fact_Activity_DSSmart"
    }
    library {
      whl = "s3://ds-data-databricks-${var.environment}/artifacts/DirectSupply-0.0.0-py3-none-any.whl"
    }
    library {
      jar = "s3://ds-data-databricks-${var.environment}/libraries/redshift-jdbc42-2.1.0.10.jar"
    }
    new_cluster {
      num_workers   = 1
      spark_version = data.databricks_spark_version.latest.id
      node_type_id  = data.databricks_node_type.smallest.id
      data_security_mode = "SINGLE_USER"
      aws_attributes {
        instance_profile_arn = data.aws_iam_instance_profile.profile.arn
      }
      spark_env_vars = {
        "ENV" : "${var.environment}"
        "ROLE" : "databricks-${var.environment}-data-access"
        "BUCKET" : "ds-data-databricks-${var.environment}"
      }
      custom_tags = {
        "OwnerEmail":"datanomads@directsupply.com"
        "Application":"databricks"
        "Customer":"Direct Supply"
        "LineOfBusiness":"CIS"
        "Role":"cluster"
        "Environment":"${var.environment}"
        "Lifespan":"permanent"
      }
    }
    python_wheel_task {
      entry_point = "main_task"
      package_name = "DirectSupply"
      parameters =  [
                          "--module",
                          "data_stitching",
                          "--sub-module",
                          "dssi",
                          "--job",
                          "dim_location_ds",
                          "--conf-file",
                          "s3://ds-data-databricks-${var.environment}/configs/config.json",
                          "--env",
                          "${var.environment}",
                          "--full-refresh",
                          "1"
                      ]
    }
  }

  # 14
  task{
    task_key = "DataStitching_DSSI_Dim_Contact_DS"
    depends_on {
      task_key = "DataStitching_DSSI_Dim_Location_DS"
    }
    library {
      whl = "s3://ds-data-databricks-${var.environment}/artifacts/DirectSupply-0.0.0-py3-none-any.whl"
    }
    library {
      jar = "s3://ds-data-databricks-${var.environment}/libraries/redshift-jdbc42-2.1.0.10.jar"
    }
    new_cluster {
      num_workers   = 1
      spark_version = data.databricks_spark_version.latest.id
      node_type_id  = data.databricks_node_type.smallest.id
      data_security_mode = "SINGLE_USER"
      aws_attributes {
        instance_profile_arn = data.aws_iam_instance_profile.profile.arn
      }
      spark_env_vars = {
        "ENV" : "${var.environment}"
        "ROLE" : "databricks-${var.environment}-data-access"
        "BUCKET" : "ds-data-databricks-${var.environment}"
      }
      custom_tags = {
        "OwnerEmail":"datanomads@directsupply.com"
        "Application":"databricks"
        "Customer":"Direct Supply"
        "LineOfBusiness":"CIS"
        "Role":"cluster"
        "Environment":"${var.environment}"
        "Lifespan":"permanent"
      }

    
    }
    python_wheel_task {
      entry_point = "main_task"
      package_name = "DirectSupply"
      parameters =  [
                          "--module",
                          "data_stitching",
                          "--sub-module",
                          "dssi",
                          "--job",
                          "dim_contact_ds",
                          "--conf-file",
                          "s3://ds-data-databricks-${var.environment}/configs/config.json",
                          "--env",
                          "${var.environment}",
                          "--full-refresh",
                          "1"
                      ]
    }
  }
}

# 1. dim_date
resource "databricks_job" "job1" {
  name = "DataStitching_DSSI_Dim_Date"

  max_concurrent_runs = 2
  timeout_seconds = 21600

  library {
    whl = "s3://ds-data-databricks-${var.environment}/artifacts/DirectSupply-0.0.0-py3-none-any.whl"
  }
  new_cluster {
    num_workers   = 1
    spark_version = data.databricks_spark_version.latest.id
    node_type_id  = data.databricks_node_type.smallest.id
    data_security_mode = "SINGLE_USER"
    aws_attributes {
      instance_profile_arn = data.aws_iam_instance_profile.profile.arn
    }
    spark_env_vars = {
      "ENV" : "${var.environment}"
      "ROLE" : "databricks-${var.environment}-data-access"
      "BUCKET" : "ds-data-databricks-${var.environment}"
    }
    custom_tags = {
      "OwnerEmail":"datanomads@directsupply.com"
      "Application":"databricks"
      "Customer":"Direct Supply"
      "LineOfBusiness":"CIS"
      "Role":"cluster"
      "Environment":"${var.environment}"
      "Lifespan":"permanent"
    }
  }
  python_wheel_task {
    entry_point = "main_task"
    package_name = "DirectSupply"
    parameters =  [
                        "--module",
                        "data_stitching",
                        "--sub-module",
                        "dssi",
                        "--job",
                        "dim_date",
                        "--conf-file",
                        "s3://ds-data-databricks-${var.environment}/configs/config.json",
                        "--env",
                        "${var.environment}",
                        "--full-refresh",
                        "1"
                    ]
  }
}
  

# 2. dim_contact_ds
resource "databricks_job" "job2" {
  name = "DataStitching_DSSI_Dim_Contact_DS"

  max_concurrent_runs = 2
  timeout_seconds = 21600

  library {
    whl = "s3://ds-data-databricks-${var.environment}/artifacts/DirectSupply-0.0.0-py3-none-any.whl"
  }

  new_cluster {
    num_workers   = 1
    spark_version = data.databricks_spark_version.latest.id
    node_type_id  = data.databricks_node_type.smallest.id
    data_security_mode = "SINGLE_USER"
    aws_attributes {
      instance_profile_arn = data.aws_iam_instance_profile.profile.arn
    }
    spark_env_vars = {
      "ENV" : "${var.environment}"
      "ROLE" : "databricks-${var.environment}-data-access"
      "BUCKET" : "ds-data-databricks-${var.environment}"
    }
    custom_tags = {
      "OwnerEmail":"datanomads@directsupply.com"
      "Application":"databricks"
      "Customer":"Direct Supply"
      "LineOfBusiness":"CIS"
      "Role":"cluster"
      "Environment":"${var.environment}"
      "Lifespan":"permanent"
    }
  }

  python_wheel_task {
    entry_point = "main_task"
    package_name = "DirectSupply"
    parameters =  [
                        "--module",
                        "data_stitching",
                        "--sub-module",
                        "dssi",
                        "--job",
                        "dim_contact_ds",
                        "--conf-file",
                        "s3://ds-data-databricks-${var.environment}/configs/config.json",
                        "--env",
                        "${var.environment}",
                        "--full-refresh",
                        "1"
                    ]
  }
}

# 3. dim_contact_dssi
resource "databricks_job" "job3" {
  name = "DataStitching_DSSI_Dim_Contact"

  max_concurrent_runs = 2
  timeout_seconds = 21600

  library {
    whl = "s3://ds-data-databricks-${var.environment}/artifacts/DirectSupply-0.0.0-py3-none-any.whl"
  }

  new_cluster {
    num_workers   = 1
    spark_version = data.databricks_spark_version.latest.id
    node_type_id  = data.databricks_node_type.smallest.id
    data_security_mode = "SINGLE_USER"
    aws_attributes {
      instance_profile_arn = data.aws_iam_instance_profile.profile.arn
    }
    spark_env_vars = {
      "ENV" : "${var.environment}"
      "ROLE" : "databricks-${var.environment}-data-access"
      "BUCKET" : "ds-data-databricks-${var.environment}"
    }
    custom_tags = {
      "OwnerEmail":"datanomads@directsupply.com"
      "Application":"databricks"
      "Customer":"Direct Supply"
      "LineOfBusiness":"CIS"
      "Role":"cluster"
      "Environment":"${var.environment}"
      "Lifespan":"permanent"
    }

  
  }

  python_wheel_task {
    entry_point = "main_task"
    package_name = "DirectSupply"
    parameters =  [
                        "--module",
                        "data_stitching",
                        "--sub-module",
                        "dssi",
                        "--job",
                        "dim_contact_dssi",
                        "--conf-file",
                        "s3://ds-data-databricks-${var.environment}/configs/config.json",
                        "--env",
                        "${var.environment}",
                        "--full-refresh",
                        "1"
                    ]
  }
}

# 4. dim_location_ds
resource "databricks_job" "job4" {
  name = "DataStitching_DSSI_Dim_Location_DS"

  max_concurrent_runs = 2
  timeout_seconds = 21600

  library {
    whl = "s3://ds-data-databricks-${var.environment}/artifacts/DirectSupply-0.0.0-py3-none-any.whl"
  }
  library {
    jar = "s3://ds-data-databricks-${var.environment}/libraries/redshift-jdbc42-2.1.0.10.jar"
  }

  new_cluster {
    num_workers   = 1
    spark_version = data.databricks_spark_version.latest.id
    node_type_id  = data.databricks_node_type.smallest.id
    data_security_mode = "SINGLE_USER"
    aws_attributes {
      instance_profile_arn = data.aws_iam_instance_profile.profile.arn
    }
    spark_env_vars = {
      "ENV" : "${var.environment}"
      "ROLE" : "databricks-${var.environment}-data-access"
      "BUCKET" : "ds-data-databricks-${var.environment}"
    }
    custom_tags = {
      "OwnerEmail":"datanomads@directsupply.com"
      "Application":"databricks"
      "Customer":"Direct Supply"
      "LineOfBusiness":"CIS"
      "Role":"cluster"
      "Environment":"${var.environment}"
      "Lifespan":"permanent"
    }

  
  }

  python_wheel_task {
    entry_point = "main_task"
    package_name = "DirectSupply"
    parameters =  [
                        "--module",
                        "data_stitching",
                        "--sub-module",
                        "dssi",
                        "--job",
                        "dim_location_ds",
                        "--conf-file",
                        "s3://ds-data-databricks-${var.environment}/configs/config.json",
                        "--env",
                        "${var.environment}",
                        "--full-refresh",
                        "1"
                    ]
  }
}

# 5. dim_location_dssi
resource "databricks_job" "job5" {
  name = "DataStitching_DSSI_Dim_Location"

  max_concurrent_runs = 2
  timeout_seconds = 21600

  library {
    whl = "s3://ds-data-databricks-${var.environment}/artifacts/DirectSupply-0.0.0-py3-none-any.whl"
  }

  new_cluster {
    num_workers   = 1
    spark_version = data.databricks_spark_version.latest.id
    node_type_id  = data.databricks_node_type.smallest.id
    data_security_mode = "SINGLE_USER"
    aws_attributes {
      instance_profile_arn = data.aws_iam_instance_profile.profile.arn
    }
    spark_env_vars = {
      "ENV" : "${var.environment}"
      "ROLE" : "databricks-${var.environment}-data-access"
      "BUCKET" : "ds-data-databricks-${var.environment}"
    }
    custom_tags = {
      "OwnerEmail":"datanomads@directsupply.com"
      "Application":"databricks"
      "Customer":"Direct Supply"
      "LineOfBusiness":"CIS"
      "Role":"cluster"
      "Environment":"${var.environment}"
      "Lifespan":"permanent"
    }

  
  }

  python_wheel_task {
    entry_point = "main_task"
    package_name = "DirectSupply"
    parameters =  [
                        "--module",
                        "data_stitching",
                        "--sub-module",
                        "dssi",
                        "--job",
                        "dim_location_dssi",
                        "--conf-file",
                        "s3://ds-data-databricks-${var.environment}/configs/config.json",
                        "--env",
                        "${var.environment}",
                        "--full-refresh",
                        "1"
                    ]
  }
}

# 6. fact_order_dssi
resource "databricks_job" "job6" {
  name = "DataStitching_DSSI_Fact_Order"

  max_concurrent_runs = 2
  timeout_seconds = 21600

  library {
    whl = "s3://ds-data-databricks-${var.environment}/artifacts/DirectSupply-0.0.0-py3-none-any.whl"
  }

  new_cluster {
    num_workers   = 2
    spark_version = data.databricks_spark_version.latest.id
    node_type_id  = data.databricks_node_type.smallest.id
    data_security_mode = "SINGLE_USER"
    aws_attributes {
      instance_profile_arn = data.aws_iam_instance_profile.profile.arn
    }
    spark_env_vars = {
      "ENV" : "${var.environment}"
      "ROLE" : "databricks-${var.environment}-data-access"
      "BUCKET" : "ds-data-databricks-${var.environment}"
    }
    custom_tags = {
      "OwnerEmail":"datanomads@directsupply.com"
      "Application":"databricks"
      "Customer":"Direct Supply"
      "LineOfBusiness":"CIS"
      "Role":"cluster"
      "Environment":"${var.environment}"
      "Lifespan":"permanent"
    }

  
  }

  python_wheel_task {
    entry_point = "main_task"
    package_name = "DirectSupply"
    parameters =  [
                        "--module",
                        "data_stitching",
                        "--sub-module",
                        "dssi",
                        "--job",
                        "fact_order_dssi",
                        "--conf-file",
                        "s3://ds-data-databricks-${var.environment}/configs/config.json",
                        "--env",
                        "${var.environment}",
                        "--full-refresh",
                        "1"
                    ]
  }
}

# 7. fact_activity_dssmart
resource "databricks_job" "job7" {
  name = "DataStitching_DSSI_Fact_Activity_DSSmart"

  max_concurrent_runs = 2
  timeout_seconds = 21600

  library {
    whl = "s3://ds-data-databricks-${var.environment}/artifacts/DirectSupply-0.0.0-py3-none-any.whl"
  }
  library {
    jar = "s3://ds-data-databricks-${var.environment}/libraries/redshift-jdbc42-2.1.0.10.jar"
  }

  new_cluster {
    num_workers   = 1
    spark_version = data.databricks_spark_version.latest.id
    node_type_id  = data.databricks_node_type.smallest.id
    data_security_mode = "SINGLE_USER"
    aws_attributes {
      instance_profile_arn = data.aws_iam_instance_profile.profile.arn
    }
    spark_env_vars = {
      "ENV" : "${var.environment}"
      "ROLE" : "databricks-${var.environment}-data-access"
      "BUCKET" : "ds-data-databricks-${var.environment}"
    }
    custom_tags = {
      "OwnerEmail":"datanomads@directsupply.com"
      "Application":"databricks"
      "Customer":"Direct Supply"
      "LineOfBusiness":"CIS"
      "Role":"cluster"
      "Environment":"${var.environment}"
      "Lifespan":"permanent"
    }

 
  }

  python_wheel_task {
    entry_point = "main_task"
    package_name = "DirectSupply"
    parameters =  [
                        "--module",
                        "data_stitching",
                        "--sub-module",
                        "dssi",
                        "--job",
                        "fact_activity_dssmart",
                        "--conf-file",
                        "s3://ds-data-databricks-${var.environment}/configs/config.json",
                        "--env",
                        "${var.environment}",
                        "--full-refresh",
                        "1"
                    ]
  }
}

# 8. dim_contact_dse
resource "databricks_job" "job8" {
  name = "DataStitching_DSHE_Dim_Contact_Dse"

  max_concurrent_runs = 2
  timeout_seconds = 21600

  library {
    whl = "s3://ds-data-databricks-${var.environment}/artifacts/DirectSupply-0.0.0-py3-none-any.whl"
  }

  new_cluster {
    num_workers   = 1
    spark_version = data.databricks_spark_version.latest.id
    node_type_id  = data.databricks_node_type.smallest.id
    data_security_mode = "SINGLE_USER"
    aws_attributes {
      instance_profile_arn = data.aws_iam_instance_profile.profile.arn
    }
    spark_env_vars = {
      "ENV" : "${var.environment}"
      "ROLE" : "databricks-${var.environment}-data-access"
      "BUCKET" : "ds-data-databricks-${var.environment}"
    }
    custom_tags = {
      "OwnerEmail":"datanomads@directsupply.com"
      "Application":"databricks"
      "Customer":"Direct Supply"
      "LineOfBusiness":"CIS"
      "Role":"cluster"
      "Environment":"${var.environment}"
      "Lifespan":"permanent"
    }

  
  }

  python_wheel_task {
    entry_point = "main_task"
    package_name = "DirectSupply"
    parameters =  [
                        "--module",
                        "data_stitching",
                        "--sub-module",
                        "dshe",
                        "--job",
                        "dim_contact_dse",
                        "--conf-file",
                        "s3://ds-data-databricks-${var.environment}/configs/config.json",
                        "--env",
                        "${var.environment}",
                        "--full-refresh",
                        "1"
                    ]
  }
}

# 9. dim_location_dse
resource "databricks_job" "job9" {
  name = "DataStitching_DSHE_Dim_Location_Dse"

  max_concurrent_runs = 2
  timeout_seconds = 21600

  library {
    whl = "s3://ds-data-databricks-${var.environment}/artifacts/DirectSupply-0.0.0-py3-none-any.whl"
  }

  new_cluster {
    num_workers   = 1
    spark_version = data.databricks_spark_version.latest.id
    node_type_id  = data.databricks_node_type.smallest.id
    data_security_mode = "SINGLE_USER"
    aws_attributes {
      instance_profile_arn = data.aws_iam_instance_profile.profile.arn
    }
    spark_env_vars = {
      "ENV" : "${var.environment}"
      "ROLE" : "databricks-${var.environment}-data-access"
      "BUCKET" : "ds-data-databricks-${var.environment}"
    }
    custom_tags = {
      "OwnerEmail":"datanomads@directsupply.com"
      "Application":"databricks"
      "Customer":"Direct Supply"
      "LineOfBusiness":"CIS"
      "Role":"cluster"
      "Environment":"${var.environment}"
      "Lifespan":"permanent"
    }

  
  }

  python_wheel_task {
    entry_point = "main_task"
    package_name = "DirectSupply"
    parameters =  [
                        "--module",
                        "data_stitching",
                        "--sub-module",
                        "dshe",
                        "--job",
                        "dim_location_dse",
                        "--conf-file",
                        "s3://ds-data-databricks-${var.environment}/configs/config.json",
                        "--env",
                        "${var.environment}",
                        "--full-refresh",
                        "1"
                    ]
  }
}

# 10. dim_order_dse_channel
# change
resource "databricks_job" "job10" {
  name = "DataStitching_DSHE_Dim_Order_Dse_Channel"

  max_concurrent_runs = 2
  timeout_seconds = 21600

  library {
    whl = "s3://ds-data-databricks-${var.environment}/artifacts/DirectSupply-0.0.0-py3-none-any.whl"
  }

  new_cluster {
    num_workers   = 1
    spark_version = data.databricks_spark_version.latest.id
    node_type_id  = data.databricks_node_type.smallest.id
    data_security_mode = "SINGLE_USER"
    aws_attributes {
      instance_profile_arn = data.aws_iam_instance_profile.profile.arn
    }
    spark_env_vars = {
      "ENV" : "${var.environment}"
      "ROLE" : "databricks-${var.environment}-data-access"
      "BUCKET" : "ds-data-databricks-${var.environment}"
    }
    custom_tags = {
      "OwnerEmail":"datanomads@directsupply.com"
      "Application":"databricks"
      "Customer":"Direct Supply"
      "LineOfBusiness":"CIS"
      "Role":"cluster"
      "Environment":"${var.environment}"
      "Lifespan":"permanent"
    }

 
  }

  python_wheel_task {
    entry_point = "main_task"
    package_name = "DirectSupply"
    parameters =  [
                        "--module",
                        "data_stitching",
                        "--sub-module",
                        "dshe",
                        "--job",
                        "dim_order_dse_channel",
                        "--conf-file",
                        "s3://ds-data-databricks-${var.environment}/configs/config.json",
                        "--env",
                        "${var.environment}",
                        "--full-refresh",
                        "1"
                    ]
  }
}

# 11. dim_order_dse_lob
# change
resource "databricks_job" "job11" {
  name = "DataStitching_DSHE_Dim_Order_Dse_Lob"

  max_concurrent_runs = 2
  timeout_seconds = 21600

  library {
    whl = "s3://ds-data-databricks-${var.environment}/artifacts/DirectSupply-0.0.0-py3-none-any.whl"
  }

  new_cluster {
    num_workers   = 1
    spark_version = data.databricks_spark_version.latest.id
    node_type_id  = data.databricks_node_type.smallest.id
    data_security_mode = "SINGLE_USER"
    aws_attributes {
      instance_profile_arn = data.aws_iam_instance_profile.profile.arn
    }
    spark_env_vars = {
      "ENV" : "${var.environment}"
      "ROLE" : "databricks-${var.environment}-data-access"
      "BUCKET" : "ds-data-databricks-${var.environment}"
    }
    custom_tags = {
      "OwnerEmail":"datanomads@directsupply.com"
      "Application":"databricks"
      "Customer":"Direct Supply"
      "LineOfBusiness":"CIS"
      "Role":"cluster"
      "Environment":"${var.environment}"
      "Lifespan":"permanent"
    }

  
  }

  python_wheel_task {
    entry_point = "main_task"
    package_name = "DirectSupply"
    parameters =  [
                        "--module",
                        "data_stitching",
                        "--sub-module",
                        "dshe",
                        "--job",
                        "dim_order_dse_lob",
                        "--conf-file",
                        "s3://ds-data-databricks-${var.environment}/configs/config.json",
                        "--env",
                        "${var.environment}",
                        "--full-refresh",
                        "1"
                    ]
  }
}


# 12. fact_login_tels
resource "databricks_job" "job12" {
  name = "DataStitching_DSHE_Fact_Login_Tels"

  max_concurrent_runs = 2
  timeout_seconds = 21600

  library {
    whl = "s3://ds-data-databricks-${var.environment}/artifacts/DirectSupply-0.0.0-py3-none-any.whl"
  }

  new_cluster {
    num_workers   = 2
    spark_version = data.databricks_spark_version.latest.id
    node_type_id  = data.databricks_node_type.smallest.id
    data_security_mode = "SINGLE_USER"
    aws_attributes {
      instance_profile_arn = data.aws_iam_instance_profile.profile.arn
    }
    spark_env_vars = {
      "ENV" : "${var.environment}"
      "ROLE" : "databricks-${var.environment}-data-access"
      "BUCKET" : "ds-data-databricks-${var.environment}"
    }
    custom_tags = {
      "OwnerEmail":"datanomads@directsupply.com"
      "Application":"databricks"
      "Customer":"Direct Supply"
      "LineOfBusiness":"CIS"
      "Role":"cluster"
      "Environment":"${var.environment}"
      "Lifespan":"permanent"
    }

  
  }

  python_wheel_task {
    entry_point = "main_task"
    package_name = "DirectSupply"
    parameters =  [
                        "--module",
                        "data_stitching",
                        "--sub-module",
                        "dshe",
                        "--job",
                        "fact_login_tels",
                        "--conf-file",
                        "s3://ds-data-databricks-${var.environment}/configs/config.json",
                        "--env",
                        "${var.environment}",
                        "--full-refresh",
                        "1"
                    ]
  }
}

# 13. fact_order_dse
# change
resource "databricks_job" "job13" {
  name = "DataStitching_DSHE_Fact_Order_Dse"

  max_concurrent_runs = 2
  timeout_seconds = 21600

  library {
    whl = "s3://ds-data-databricks-${var.environment}/artifacts/DirectSupply-0.0.0-py3-none-any.whl"
  }

  new_cluster {
    num_workers   = 2
    spark_version = data.databricks_spark_version.latest.id
    node_type_id  = data.databricks_node_type.smallest.id
    data_security_mode = "SINGLE_USER"
    aws_attributes {
      instance_profile_arn = data.aws_iam_instance_profile.profile.arn
    }
    spark_env_vars = {
      "ENV" : "${var.environment}"
      "ROLE" : "databricks-${var.environment}-data-access"
      "BUCKET" : "ds-data-databricks-${var.environment}"
    }
    custom_tags = {
      "OwnerEmail":"datanomads@directsupply.com"
      "Application":"databricks"
      "Customer":"Direct Supply"
      "LineOfBusiness":"CIS"
      "Role":"cluster"
      "Environment":"${var.environment}"
      "Lifespan":"permanent"
    }

  
  }

  python_wheel_task {
    entry_point = "main_task"
    package_name = "DirectSupply"
    parameters =  [
                        "--module",
                        "data_stitching",
                        "--sub-module",
                        "dshe",
                        "--job",
                        "fact_order_dse",
                        "--conf-file",
                        "s3://ds-data-databricks-${var.environment}/configs/config.json",
                        "--env",
                        "${var.environment}",
                        "--full-refresh",
                        "1"
                    ]
  }
}

# 14. dim_product_dse
resource "databricks_job" "job14" {
  name = "DataStitching_DSHE_Dim_Product_Dse"

  max_concurrent_runs = 2
  timeout_seconds = 21600

  library {
    whl = "s3://ds-data-databricks-${var.environment}/artifacts/DirectSupply-0.0.0-py3-none-any.whl"
  }
  new_cluster {
    num_workers   = 1
    spark_version = data.databricks_spark_version.latest.id
    node_type_id  = data.databricks_node_type.smallest.id
    data_security_mode = "SINGLE_USER"
    aws_attributes {
      instance_profile_arn = data.aws_iam_instance_profile.profile.arn
    }
    spark_env_vars = {
      "ENV" : "${var.environment}"
      "ROLE" : "databricks-${var.environment}-data-access"
      "BUCKET" : "ds-data-databricks-${var.environment}"
    }
    custom_tags = {
      "OwnerEmail":"datanomads@directsupply.com"
      "Application":"databricks"
      "Customer":"Direct Supply"
      "LineOfBusiness":"CIS"
      "Role":"cluster"
      "Environment":"${var.environment}"
      "Lifespan":"permanent"
    }
  }
  python_wheel_task {
    entry_point = "main_task"
    package_name = "DirectSupply"
    parameters =  [
                        "--module",
                        "data_stitching",
                        "--sub-module",
                        "dshe",
                        "--job",
                        "dim_product_dse",
                        "--conf-file",
                        "s3://ds-data-databricks-${var.environment}/configs/config.json",
                        "--env",
                        "${var.environment}",
                        "--full-refresh",
                        "1"
                    ]
  }
}

# 15. documentation
resource "databricks_job" "data_documentation_job" {
  name = "DataStitching_Documentation"

  max_concurrent_runs = 2
  timeout_seconds = 10800

  library {
    whl = "s3://ds-data-databricks-${var.environment}/artifacts/DirectSupply-0.0.0-py3-none-any.whl"
  }
  new_cluster {
    num_workers   = 1
    spark_version = data.databricks_spark_version.latest.id
    node_type_id  = data.databricks_node_type.smallest.id
    data_security_mode = "SINGLE_USER"
    aws_attributes {
      instance_profile_arn = data.aws_iam_instance_profile.profile.arn
    }
    spark_env_vars = {
      "ENV" : "${var.environment}"
      "ROLE" : "databricks-${var.environment}-data-access"
      "BUCKET" : "ds-data-databricks-${var.environment}"
    }
    custom_tags = {
      "OwnerEmail":"datanomads@directsupply.com"
      "Application":"databricks"
      "Customer":"Direct Supply"
      "LineOfBusiness":"CIS"
      "Role":"cluster"
      "Environment":"${var.environment}"
      "Lifespan":"permanent"
    }
  }
  python_wheel_task {
    entry_point = "main_task"
    package_name = "DirectSupply"
    parameters =  [
                        "--module",
                        "data_stitching",
                        "--sub-module",
                        "misc",
                        "--job",
                        "documentation",
                        "--conf-file",
                        "s3://ds-data-databricks-${var.environment}/configs/config.json",
                        "--env",
                        "${var.environment}",
                        "--full-refresh",
                        "0"
                    ]
  }
}

# Permissions

# 0
resource "databricks_permissions" "job0_perms" {
  job_id = databricks_job.job0.id

  access_control {
    group_name       = "sys_job_view"
    permission_level = "CAN_VIEW"
  }

  access_control {
    group_name       = "sys_job_run"
    permission_level = "CAN_MANAGE_RUN"
  }

  access_control {
    group_name       = "sys_job_all"
    permission_level = "CAN_MANAGE"
  }
}

# 1
resource "databricks_permissions" "job1_perms" {
  job_id = databricks_job.job1.id

  access_control {
    group_name       = "sys_job_view"
    permission_level = "CAN_VIEW"
  }

  access_control {
    group_name       = "sys_job_run"
    permission_level = "CAN_MANAGE_RUN"
  }

  access_control {
    group_name       = "sys_job_all"
    permission_level = "CAN_MANAGE"
  }
}

# 2
resource "databricks_permissions" "job2_perms" {
  job_id = databricks_job.job2.id

  access_control {
    group_name       = "sys_job_view"
    permission_level = "CAN_VIEW"
  }

  access_control {
    group_name       = "sys_job_run"
    permission_level = "CAN_MANAGE_RUN"
  }

  access_control {
    group_name       = "sys_job_all"
    permission_level = "CAN_MANAGE"
  }
}

# 3
resource "databricks_permissions" "job3_perms" {
  job_id = databricks_job.job3.id

  access_control {
    group_name       = "sys_job_view"
    permission_level = "CAN_VIEW"
  }

  access_control {
    group_name       = "sys_job_run"
    permission_level = "CAN_MANAGE_RUN"
  }

  access_control {
    group_name       = "sys_job_all"
    permission_level = "CAN_MANAGE"
  }
}

# 4
resource "databricks_permissions" "job4_perms" {
  job_id = databricks_job.job4.id

  access_control {
    group_name       = "sys_job_view"
    permission_level = "CAN_VIEW"
  }

  access_control {
    group_name       = "sys_job_run"
    permission_level = "CAN_MANAGE_RUN"
  }

  access_control {
    group_name       = "sys_job_all"
    permission_level = "CAN_MANAGE"
  }
}


# 5
resource "databricks_permissions" "job5_perms" {
  job_id = databricks_job.job5.id

  access_control {
    group_name       = "sys_job_view"
    permission_level = "CAN_VIEW"
  }

  access_control {
    group_name       = "sys_job_run"
    permission_level = "CAN_MANAGE_RUN"
  }

  access_control {
    group_name       = "sys_job_all"
    permission_level = "CAN_MANAGE"
  }
}

# 6
resource "databricks_permissions" "job6_perms" {
  job_id = databricks_job.job6.id

  access_control {
    group_name       = "sys_job_view"
    permission_level = "CAN_VIEW"
  }

  access_control {
    group_name       = "sys_job_run"
    permission_level = "CAN_MANAGE_RUN"
  }

  access_control {
    group_name       = "sys_job_all"
    permission_level = "CAN_MANAGE"
  }
}


# 7
resource "databricks_permissions" "job7_perms" {
  job_id = databricks_job.job7.id

  access_control {
    group_name       = "sys_job_view"
    permission_level = "CAN_VIEW"
  }

  access_control {
    group_name       = "sys_job_run"
    permission_level = "CAN_MANAGE_RUN"
  }

  access_control {
    group_name       = "sys_job_all"
    permission_level = "CAN_MANAGE"
  }
}

# 8
resource "databricks_permissions" "job8_perms" {
  job_id = databricks_job.job8.id

  access_control {
    group_name       = "sys_job_view"
    permission_level = "CAN_VIEW"
  }

  access_control {
    group_name       = "sys_job_run"
    permission_level = "CAN_MANAGE_RUN"
  }

  access_control {
    group_name       = "sys_job_all"
    permission_level = "CAN_MANAGE"
  }
}

# 9
resource "databricks_permissions" "job9_perms" {
  job_id = databricks_job.job9.id

  access_control {
    group_name       = "sys_job_view"
    permission_level = "CAN_VIEW"
  }

  access_control {
    group_name       = "sys_job_run"
    permission_level = "CAN_MANAGE_RUN"
  }

  access_control {
    group_name       = "sys_job_all"
    permission_level = "CAN_MANAGE"
  }
}

# 10
resource "databricks_permissions" "job10_perms" {
  job_id = databricks_job.job10.id

  access_control {
    group_name       = "sys_job_view"
    permission_level = "CAN_VIEW"
  }

  access_control {
    group_name       = "sys_job_run"
    permission_level = "CAN_MANAGE_RUN"
  }

  access_control {
    group_name       = "sys_job_all"
    permission_level = "CAN_MANAGE"
  }
}


# 11
resource "databricks_permissions" "job11_perms" {
  job_id = databricks_job.job11.id

  access_control {
    group_name       = "sys_job_view"
    permission_level = "CAN_VIEW"
  }

  access_control {
    group_name       = "sys_job_run"
    permission_level = "CAN_MANAGE_RUN"
  }

  access_control {
    group_name       = "sys_job_all"
    permission_level = "CAN_MANAGE"
  }
}

# 12
resource "databricks_permissions" "job12_perms" {
  job_id = databricks_job.job12.id

  access_control {
    group_name       = "sys_job_view"
    permission_level = "CAN_VIEW"
  }

  access_control {
    group_name       = "sys_job_run"
    permission_level = "CAN_MANAGE_RUN"
  }

  access_control {
    group_name       = "sys_job_all"
    permission_level = "CAN_MANAGE"
  }
}

#13
resource "databricks_permissions" "job13_perms" {
  job_id = databricks_job.job13.id

  access_control {
    group_name       = "sys_job_view"
    permission_level = "CAN_VIEW"
  }

  access_control {
    group_name       = "sys_job_run"
    permission_level = "CAN_MANAGE_RUN"
  }

  access_control {
    group_name       = "sys_job_all"
    permission_level = "CAN_MANAGE"
  }
}

#14
resource "databricks_permissions" "job14_perms" {
  job_id = databricks_job.job14.id

  access_control {
    group_name       = "sys_job_view"
    permission_level = "CAN_VIEW"
  }

  access_control {
    group_name       = "sys_job_run"
    permission_level = "CAN_MANAGE_RUN"
  }

  access_control {
    group_name       = "sys_job_all"
    permission_level = "CAN_MANAGE"
  }
}

#15
resource "databricks_permissions" "documentation_job_perms" {
  job_id = databricks_job.data_documentation_job.id

  access_control {
    group_name       = "sys_job_view"
    permission_level = "CAN_VIEW"
  }

  access_control {
    group_name       = "sys_job_run"
    permission_level = "CAN_MANAGE_RUN"
  }

  access_control {
    group_name       = "sys_job_all"
    permission_level = "CAN_MANAGE"
  }
}

