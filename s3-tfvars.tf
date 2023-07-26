module "aws_tfvars_s3" {
  source = "github.com/dxw/terraform-aws-tfvars-s3?ref=v0.2.0"

  project_name                    = local.project_name_hash
  enable_s3_bucket_logging        = local.tfvars_s3_enable_s3_bucket_logging
  logging_bucket_retention        = local.tfvars_s3_logging_bucket_retention
  tfvars_files                    = local.tfvars_s3_tfvars_files
  tfvars_restrict_access_user_ids = local.tfvars_s3_tfvars_restrict_access_user_ids
}
