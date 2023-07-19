locals {
  project_name                       = var.project_name
  aws_region                         = var.aws_region
  tfvars_s3_enable_s3_bucket_logging = var.tfvars_s3_enable_s3_bucket_logging
  tfvars_s3_logging_bucket_retention = var.tfvars_s3_logging_bucket_retention

  default_tags = {
    Project = local.project_name,
  }
}
