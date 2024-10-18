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

variable "enable_delete_default_resources" {
  description = "Creates a Lambda function which deletes all default VPCs and resources within them. This only needs to be ran once, either through the AWS console or via the AWS CLI"
  type        = bool
}

variable "delete_default_resources_lambda_kms_encryption" {
  description = "Conditionally encrypt the Delete Default Resources Lambda logs with KMS"
  type        = bool
}

variable "delete_default_resources_log_retention" {
  description = "Log retention for the Delete Default Resources Lambda"
  type        = number
}

variable "enable_route53_root_hosted_zone" {
  description = "Conditionally create Route53 hosted zone, which will contain the DNS records for resources launched within the account."
  type        = bool
}

variable "route53_root_hosted_zone_domain_name" {
  description = "Route53 root hosted zone domain name"
  type        = string
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

variable "codestar_connections" {
  description = "CodeStar connections to create"
  type = map(
    object({
      provider_type = string,
    })
  )
}

variable "enable_ssm_dhmc" {
  description = "Enables SSM Default Host Management Configuration"
  type        = bool
}

variable "logging_bucket_retention" {
  description = "Logging bucket retention in days. Set to 0 to keep all logs."
  type        = number
}

variable "datadog_api_key" {
  description = "Datadog API key"
  type        = string
  sensitive   = true
}

variable "datadog_app_key" {
  description = "Datadog App key"
  type        = string
  sensitive   = true
}

variable "datadog_region" {
  description = "Datadog region"
  type        = string
}

variable "enable_datadog_aws_integration" {
  description = "Conditionally create the datadog AWS integration role (https://docs.datadoghq.com/integrations/guide/aws-terraform-setup/) and configure the datadog integration"
  type        = bool
}

variable "enable_datadog_forwarder" {
  description = "Conditionally launch Datadog AWS service log forwarder lambda"
  type        = bool
}

variable "datadog_forwarder_log_retention" {
  description = "Datadog Forwarder S3 bucket retention in days. Set to 0 to keep all logs."
  type        = number
}

variable "datadog_forwarder_store_failed_events" {
  description = "Set environment variable DD_STORE_FAILED_EVENTS on the Forwarder. Set to true to enable the forwarder to also store event data in the S3 bucket"
  type        = bool
}

variable "datadog_forwarder_enhanced_metrics" {
  description = "Set the environment variable DD_ENHANCED_METRICS on the Forwarder. Set to false to stop the Forwarder from generating enhanced metrics itself, but it will still forward custom metrics from other lambdas."
  type        = bool
}

variable "custom_iam_roles" {
  type = map(object({
    description = string
    policies = map(object({
      description = string
      Version     = string
      Statement = list(object({
        Action   = list(string)
        Effect   = string
        Resource = string
      }))
    }))
    assume_role_policy = object({
      Version = string
      Statement = list(object({
        Action    = list(string)
        Effect    = string
        Principal = map(string)
      }))
    })
  }))
  description = "Configure custom IAM roles/policies"
}
