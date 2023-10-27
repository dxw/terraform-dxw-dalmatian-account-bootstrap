variable "project_name" {
  description = "Project name to be used as a prefix for all resources"
  type        = string
}

variable "aws_region" {
  description = "AWS region in which to launch resources"
  type        = string
}

variable "enable_s3_tfvars" {
  description = "enable_s3_tfvars"
  type        = bool
}

variable "tfvars_s3_enable_s3_bucket_logging" {
  description = "Enable S3 bucket logging on the tfvars S3 bucket"
  type        = bool
  default     = true
}

variable "tfvars_s3_logging_bucket_retention" {
  description = "tfvars S3 Logging bucket retention in days. Set to 0 to keep all logs."
  type        = number
  default     = 30
}

variable "tfvars_s3_tfvars_files" {
  description = "Map of objects containing tfvar file paths"
  type = map(
    object({
      path = string
      key  = optional(string, "")
      }
  ))
  default = {}
}

variable "tfvars_s3_tfvars_restrict_access_user_ids" {
  description = "List of AWS User IDs that require access to the tfvars S3 bucket. If left empty, all users within the AWS account will have access"
  type        = list(string)
  default     = []

}

variable "enable_cloudtrail" {
  description = "Enable Cloudtrail"
  type        = bool
}

variable "cloudtrail_kms_encryption" {
  description = "Use KMS encryption with CloudTrail"
  type        = bool
}

variable "cloudtrail_log_retention" {
  description = "Cloudtrail log retention in days. Set to 0 to keep all logs."
  type        = number
}

variable "cloudtrail_log_prefix" {
  description = "Cloudtrail log prefix"
  type        = string
}

variable "cloudtrail_s3_access_logs" {
  description = "Enable CloudTrail S3 bucket access logging"
  type        = bool
}

variable "cloudtrail_athena_glue_tables" {
  description = "Create the Glue database and tables for CloudTrail to be used with Athena"
  type        = bool
}

variable "cloudtrail_athena_s3_output_retention" {
  description = "CloudTrail Athena Set to 0 to keep all logs"
  type        = number
}

variable "cloudtrail_athena_s3_output_kms_encryption" {
  description = "Use KMS encryption with the CloudTrail Athena output S3 bucket"
  type        = bool
}

variable "enable_cloudwatch_slack_alerts" {
  description = "Enable CloudWatch Slack alerts. This creates an SNS topic to which alerts and pipelines can send messages, which are then picked up by a Lambda function that forwards them to a Slack webhook."
  type        = bool
}

variable "cloudwatch_slack_alerts_hook_url" {
  description = "The Slack webhook URL for CloudWatch alerts"
  type        = string
}

variable "cloudwatch_slack_alerts_channel" {
  description = "The Slack channel for CloudWatch alerts"
  type        = string
}

variable "cloudwatch_slack_alerts_kms_encryption" {
  description = "Use KMS encryption with the Slack Alerts SNS topic and logs"
  type        = bool
}

variable "cloudwatch_slack_alerts_log_retention" {
  description = "Cloudwatch Slack Alerts log retention. Set to 0 to keep all logs"
  type        = number
}

variable "enable_cloudwatch_opsgenie_alerts" {
  description = "Enable CloudWatch Opsgenie alerts. This creates an SNS topic to which alerts and pipelines can send messages, which are then sent to the Opsgenie SNS endpoint."
  type        = bool
}

variable "cloudwatch_opsgenie_alerts_sns_endpoint" {
  description = "The Opsgenie SNS endpoint. https://support.atlassian.com/opsgenie/docs/integrate-opsgenie-with-incoming-amazon-sns/"
  type        = string
}

variable "cloudwatch_opsgenie_alerts_sns_kms_encryption" {
  description = "Use KMS encryption with the Opsgenie Alerts SNS topic"
  type        = bool
}

variable "logging_bucket_retention" {
  description = "Logging bucket retention in days. Set to 0 to keep all logs."
  type        = number
}
