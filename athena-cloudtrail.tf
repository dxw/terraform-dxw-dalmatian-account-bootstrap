resource "aws_athena_workgroup" "cloudtrail" {
  count = local.cloudtrail_athena_glue_tables ? 1 : 0

  name = "${local.project_name}-cloudtrail"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena_cloudtrail_output[0].bucket}/"

      encryption_configuration {
        encryption_option = local.cloudtrail_athena_s3_output_kms_encryption ? "SSE_KMS" : "SSE_S3"
        kms_key_arn       = local.cloudtrail_athena_s3_output_kms_encryption ? aws_kms_key.athena_cloudtrail_output[0].arn : null
      }
    }
  }
}
