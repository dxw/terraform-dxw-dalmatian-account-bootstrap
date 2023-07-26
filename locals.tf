locals {
  project_name      = var.project_name
  project_name_hash = format("%.6s", sha1(local.project_name))
  aws_region        = var.aws_region

  tfvars_s3_enable_s3_bucket_logging        = var.tfvars_s3_enable_s3_bucket_logging
  tfvars_s3_logging_bucket_retention        = var.tfvars_s3_logging_bucket_retention
  tfvars_s3_tfvars_files                    = var.tfvars_s3_tfvars_files
  tfvars_s3_tfvars_restrict_access_user_ids = var.tfvars_s3_tfvars_restrict_access_user_ids

  default_tags = {
    Project = local.project_name,
  }
}
