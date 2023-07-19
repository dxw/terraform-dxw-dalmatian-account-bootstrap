module "aws_tfvars_s3" {
  # This module currently doesn't have a Release
  # tflint-ignore: terraform_module_pinned_source
  source = "github.com/dxw/terraform-aws-tfvars-s3?ref=main"

  project_name             = local.project_name_hash
  enable_s3_bucket_logging = local.tfvars_s3_enable_s3_bucket_logging
  logging_bucket_retention = local.tfvars_s3_logging_bucket_retention
}
