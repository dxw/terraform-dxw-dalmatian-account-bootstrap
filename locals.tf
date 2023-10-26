locals {
  project_name      = var.project_name
  project_name_hash = format("%.6s", sha1(local.project_name))
  aws_region        = var.aws_region
  aws_account_id    = data.aws_caller_identity.current.account_id

  enable_s3_tfvars                          = var.enable_s3_tfvars
  tfvars_s3_enable_s3_bucket_logging        = var.tfvars_s3_enable_s3_bucket_logging
  tfvars_s3_logging_bucket_retention        = var.tfvars_s3_logging_bucket_retention
  tfvars_s3_tfvars_files                    = var.tfvars_s3_tfvars_files
  tfvars_s3_tfvars_restrict_access_user_ids = var.tfvars_s3_tfvars_restrict_access_user_ids

  enable_cloudtrail         = var.enable_cloudtrail
  cloudtrail_kms_encryption = var.cloudtrail_kms_encryption
  cloudtrail_log_retention  = var.cloudtrail_log_retention
  cloudtrail_log_prefix     = var.cloudtrail_log_prefix
  cloudtrail_s3_access_logs = var.cloudtrail_s3_access_logs && local.enable_cloudtrail

  enable_cloudwatch_slack_alerts         = var.enable_cloudwatch_slack_alerts
  cloudwatch_slack_alerts_kms_encryption = var.cloudwatch_slack_alerts_kms_encryption && local.enable_cloudwatch_slack_alerts
  cloudwatch_slack_alerts_hook_url       = var.cloudwatch_slack_alerts_hook_url
  cloudwatch_slack_alerts_channel        = var.cloudwatch_slack_alerts_channel
  cloudwatch_slack_alerts_log_retention  = var.cloudwatch_slack_alerts_log_retention

  enable_cloudwatch_opsgenie_alerts             = var.enable_cloudwatch_opsgenie_alerts
  cloudwatch_opsgenie_alerts_sns_kms_encryption = var.cloudwatch_opsgenie_alerts_sns_kms_encryption && local.enable_cloudwatch_opsgenie_alerts
  cloudwatch_opsgenie_alerts_sns_endpoint       = var.cloudwatch_opsgenie_alerts_sns_endpoint

  enable_logs_bucket       = local.cloudtrail_s3_access_logs
  logging_bucket_retention = var.logging_bucket_retention
  logs_bucket_source_arns = concat(
    local.cloudtrail_s3_access_logs ? [aws_s3_bucket.cloudtrail[0].arn] : [],
  )

  default_tags = {
    Project = local.project_name,
  }
}
