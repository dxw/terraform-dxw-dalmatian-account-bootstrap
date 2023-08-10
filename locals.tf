locals {
  project_name      = var.project_name
  project_name_hash = format("%.6s", sha1(local.project_name))
  aws_region        = var.aws_region
  aws_account_id    = data.aws_caller_identity.current.account_id

  tfvars_s3_enable_s3_bucket_logging        = var.tfvars_s3_enable_s3_bucket_logging
  tfvars_s3_logging_bucket_retention        = var.tfvars_s3_logging_bucket_retention
  tfvars_s3_tfvars_files                    = var.tfvars_s3_tfvars_files
  tfvars_s3_tfvars_restrict_access_user_ids = var.tfvars_s3_tfvars_restrict_access_user_ids

  enable_cloudtrail        = var.enable_cloudtrail
  cloudtrail_log_retention = var.cloudtrail_log_retention
  cloudtrail_log_prefix    = var.cloudtrail_log_prefix

  enable_cloudwatch_slack_alerts   = var.enable_cloudwatch_slack_alerts
  cloudwatch_slack_alerts_hook_url = var.cloudwatch_slack_alerts_hook_url
  cloudwatch_slack_alerts_channel  = var.cloudwatch_slack_alerts_channel

  default_tags = {
    Project = local.project_name,
  }
}
