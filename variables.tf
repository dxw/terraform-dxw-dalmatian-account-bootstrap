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

variable "cloudtrail_log_retention" {
  description = "Cloudtrail log retention in days. Set to 0 to keep all logs."
  type        = number
}

variable "cloudtrail_log_prefix" {
  description = "Cloudtrail log prefix"
  type        = string
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
