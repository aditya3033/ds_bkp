data "databricks_node_type" "smallest" {
  local_disk  = true
  min_cores   = 8
  category    = "General Purpose"
}

data "databricks_node_type" "memory_optimized" {
  local_disk  = true
  min_cores   = 8
  category    = "Memory Optimized"
}

data "databricks_spark_version" "latest" {
  long_term_support = false
  latest = true
  photon = false
  spark_version = "3.3.0"
}

data "aws_iam_instance_profile" "profile" {
  name = "databricks-${var.environment}-data-access"
}