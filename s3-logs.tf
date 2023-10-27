# https://github.com/aquasecurity/tfsec/issues/2081
# tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "logs" {
  count = local.enable_logs_bucket ? 1 : 0

  bucket = "${local.aws_account_id}-${local.aws_region}-${local.project_name}-logs"
}

resource "aws_s3_bucket_policy" "logs" {
  count = local.enable_logs_bucket ? 1 : 0

  bucket = aws_s3_bucket.logs[0].id
  policy = templatefile(
    "${path.module}/policies/s3-bucket-policy.json.tpl",
    {
      statement = <<EOT
      [
      ${templatefile("${path.root}/policies/s3-bucket-policy-statements/enforce-tls.json.tpl", { bucket_arn = aws_s3_bucket.logs[0].arn })},
      ${templatefile("${path.root}/policies/s3-bucket-policy-statements/log-delivery-access.json.tpl", {
      log_bucket_arn     = aws_s3_bucket.logs[0].arn
      source_bucket_arns = jsonencode(local.logs_bucket_source_arns)
      account_id         = local.aws_account_id
})}
      ]
      EOT
}
)
}

resource "aws_s3_bucket_public_access_block" "logs" {
  count = local.enable_logs_bucket ? 1 : 0

  bucket                  = aws_s3_bucket.logs[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "logs" {
  count = local.enable_logs_bucket ? 1 : 0

  bucket = aws_s3_bucket.logs[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

# Using SSE-KMS is not supported for logging buckets
# tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  count = local.enable_logs_bucket ? 1 : 0

  bucket = aws_s3_bucket.logs[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  count = local.enable_logs_bucket && local.logging_bucket_retention != 0 ? 1 : 0

  bucket = aws_s3_bucket.logs[0].id

  rule {
    id = "all_expire"

    filter {
      prefix = ""
    }

    expiration {
      days = local.logging_bucket_retention
    }

    status = "Enabled"
  }
}
