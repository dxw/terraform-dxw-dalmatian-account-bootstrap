variable "project_name" {
  description = "Project name to be used as a prefix for all resources"
  type        = string
}

variable "aws_region" {
  description = "AWS region in which to launch resources"
  type        = string
}

variable "tfvars_s3_enable_s3_bucket_logging" {
  description = "Enable S3 bucket logging on the tfvars S3 bucket"
  type        = bool
}

variable "tfvars_s3_logging_bucket_retention" {
  description = "tfvars S3 Logging bucket retention in days. Set to 0 to keep all logs."
  type        = number
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
