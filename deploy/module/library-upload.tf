locals {
  module_path = abspath("${path.module}")
}

resource "aws_s3_object" "upload_libraries" {
  for_each = fileset("${local.module_path}/libraries/", "*")
  bucket = "ds-data-databricks-${var.environment}/libraries/"
  key = each.value
  source = "${local.module_path}/libraries/${each.value}"
  etag = filemd5("${local.module_path}/libraries/${each.value}")
}