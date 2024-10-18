resource "aws_kms_key" "datadog_lambda" {
  count = local.enable_datadog_forwarder ? 1 : 0

  description             = "This key is used to encrypt bucket objects in ${aws_s3_bucket.datadog_lambda[0].id}"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_kms_alias" "datadog_lambda" {
  count = local.enable_datadog_forwarder ? 1 : 0

  name          = "alias/${local.project_name}-datadog-lambda"
  target_key_id = aws_kms_key.datadog_lambda[0].key_id
}

resource "aws_s3_bucket" "datadog_lambda" {
  count = local.enable_datadog_forwarder ? 1 : 0

  bucket = "${local.aws_account_id}-${local.project_name}-datadog-lambda"
}

resource "aws_s3_bucket_policy" "datadog_lambda" {
  count = local.enable_datadog_forwarder ? 1 : 0

  bucket = aws_s3_bucket.datadog_lambda[0].id

  policy = templatefile(
    "${path.module}/policies/s3-bucket-policy.json.tpl",
    {
      statement = <<EOT
      [
      ${templatefile("${path.root}/policies/s3-bucket-policy-statements/enforce-tls.json.tpl", {
      bucket_arn = aws_s3_bucket.datadog_lambda[0].arn,
})}
      ]
      EOT
}
)
}

resource "aws_s3_bucket_public_access_block" "datadog_lambda" {
  count = local.enable_datadog_forwarder ? 1 : 0

  bucket                  = aws_s3_bucket.datadog_lambda[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "datadog_lambda" {
  count = local.enable_datadog_forwarder ? 1 : 0

  bucket = aws_s3_bucket.datadog_lambda[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "datadog_lambda" {
  count = local.enable_datadog_forwarder ? 1 : 0

  bucket = aws_s3_bucket.datadog_lambda[0].id

  target_bucket = aws_s3_bucket.logs[0].id
  target_prefix = "s3/datadog-lambda"
}

# because datadog_forwarder_s3_kms_encryption is only true when multiple other
# vars are true, tfsec can't figure out that this will actually have kms encryption when
# enabled
#tfsec:ignore:aws-s3-encryption-customer-key tfsec:ignore:aws-s3-enable-bucket-encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "datadog_lambda" {
  count = local.enable_datadog_forwarder ? 1 : 0

  bucket = aws_s3_bucket.datadog_lambda[0].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.datadog_lambda[0].arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "datadog_lambda" {
  count = local.enable_datadog_forwarder && local.datadog_forwarder_log_retention != 0 ? 1 : 0

  bucket = aws_s3_bucket.datadog_lambda[0].id

  rule {
    id = "all_expire"

    filter {
      prefix = ""
    }

    expiration {
      days = local.datadog_forwarder_log_retention
    }

    status = "Enabled"
  }
}
