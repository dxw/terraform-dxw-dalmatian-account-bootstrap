resource "aws_kms_key" "aws_config" {
  count = local.aws_config_s3_kms_encryption ? 1 : 0

  description             = "This key is used to encrypt bucket objects in ${aws_s3_bucket.aws_config[0].id}"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_kms_alias" "aws_config" {
  count = local.aws_config_s3_kms_encryption ? 1 : 0

  name          = "alias/${local.project_name}-aws-config"
  target_key_id = aws_kms_key.aws_config[0].key_id
}

resource "aws_s3_bucket" "aws_config" {
  count = local.enable_aws_config ? 1 : 0

  bucket = "${local.aws_account_id}-${local.project_name}-aws-config"
}

resource "aws_s3_bucket_policy" "aws_config" {
  count = local.enable_aws_config ? 1 : 0

  bucket = aws_s3_bucket.aws_config[0].id

  policy = templatefile(
    "${path.module}/policies/s3-bucket-policy.json.tpl",
    {
      statement = <<EOT
      [
      ${templatefile("${path.root}/policies/s3-bucket-policy-statements/enforce-tls.json.tpl", {
      bucket_arn = aws_s3_bucket.aws_config[0].arn,
      })},
      ${templatefile("${path.root}/policies/s3-bucket-policy-statements/allow-aws-config.json.tpl", {
      bucket_arn     = aws_s3_bucket.aws_config[0].arn,
      aws_account_id = local.aws_account_id
})}
      
      ]
      EOT
}
)
}

resource "aws_s3_bucket_public_access_block" "aws_config" {
  count = local.enable_aws_config ? 1 : 0

  bucket                  = aws_s3_bucket.aws_config[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "aws_config" {
  count = local.enable_aws_config ? 1 : 0

  bucket = aws_s3_bucket.aws_config[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "aws_config" {
  count = local.enable_aws_config ? 1 : 0

  bucket = aws_s3_bucket.aws_config[0].id

  target_bucket = aws_s3_bucket.logs[0].id
  target_prefix = "s3/aws-config"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "aws_config" {
  count = local.enable_aws_config ? 1 : 0

  bucket = aws_s3_bucket.aws_config[0].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = local.aws_config_s3_kms_encryption ? aws_kms_key.aws_config[0].arn : null
      sse_algorithm     = local.aws_config_s3_kms_encryption ? "aws:kms" : "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "aws_config" {
  count = local.enable_aws_config && local.aws_config_s3_retention != 0 ? 1 : 0

  bucket = aws_s3_bucket.aws_config[0].id

  rule {
    id = "all_expire"

    filter {
      prefix = ""
    }

    expiration {
      days = local.aws_config_s3_retention
    }

    status = "Enabled"
  }
}
