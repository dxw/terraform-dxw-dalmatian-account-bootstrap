resource "aws_glue_catalog_database" "cloudtrail" {
  count = local.cloudtrail_athena_glue_tables ? 1 : 0

  name        = "${replace(local.project_name, "-", "_")}_cloudtrail"
  description = "Database for CloudTrail tables to be queried with Athena"
}

resource "aws_glue_catalog_table" "cloudtrail" {
  count = local.cloudtrail_athena_glue_tables ? 1 : 0

  name          = "cloudtrail_logs_${replace(aws_s3_bucket.cloudtrail[0].id, "-", "_")}_${aws_cloudtrail.cloudtrail[0].s3_key_prefix}"
  database_name = aws_glue_catalog_database.cloudtrail[0].name

  parameters = {
    comment        = "CloudTrail table for ${aws_s3_bucket.cloudtrail[0].id} bucket"
    EXTERNAL       = "TRUE"
    classification = "cloudtrail"
  }

  storage_descriptor {
    input_format  = "com.amazon.emr.cloudtrail.CloudTrailInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
    location      = "s3://${aws_s3_bucket.cloudtrail[0].id}/${aws_cloudtrail.cloudtrail[0].s3_key_prefix}/AWSLogs/${local.aws_account_id}/CloudTrail"

    ser_de_info {
      parameters = {
        "serialization.format" = "1"
      }
      serialization_library = "org.apache.hive.hcatalog.data.JsonSerDe"
    }

    dynamic "columns" {
      for_each = local.cloudtrail_glue_table_columns
      content {
        name = columns.key
        type = columns.value
      }
    }
  }
}
