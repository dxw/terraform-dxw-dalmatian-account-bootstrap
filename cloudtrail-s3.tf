# https://github.com/aquasecurity/tfsec/issues/2081
# tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "cloudtrail" {
  count = local.enable_cloudtrail ? 1 : 0

  bucket = "${local.aws_account_id}-${local.project_name}-cloudtrail"
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  count = local.enable_cloudtrail ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail[0].id

  # Note: The `cloudtrail_arn` can't be specified by referencing the cloudtrail resource, because
  #       this policy needs to be created before CloudTrail will allow it to be used for logging
  policy = templatefile(
    "${path.module}/policies/s3-bucket-policy.json.tpl",
    {
      statement = <<EOT
      [
      ${templatefile("${path.root}/policies/s3-bucket-policy-statements/enforce-tls.json.tpl", {
      bucket_arn = aws_s3_bucket.cloudtrail[0].arn,
    })},
      ${templatefile("${path.root}/policies/s3-bucket-policy-statements/cloudtrail-cloudwatch-logs.json.tpl",
    {
      bucket_arn     = aws_s3_bucket.cloudtrail[0].arn,
      logs_prefix    = local.cloudtrail_log_prefix,
      cloudtrail_arn = "arn:aws:cloudtrail:${local.aws_region}:${local.aws_account_id}:trail/${local.project_name}",
      account_id     = local.aws_account_id,
    }
  )
}
      ]
      EOT
}
)
}

resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  count = local.enable_cloudtrail ? 1 : 0

  bucket                  = aws_s3_bucket.cloudtrail[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "cloudtrail" {
  count = local.enable_cloudtrail ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

# Using SSE-KMS is not supported for logging buckets
# tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail" {
  count = local.enable_cloudtrail ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail" {
  count = local.enable_cloudtrail && local.cloudtrail_log_retention != 0 ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail[0].id

  rule {
    id = "all_expire"

    filter {
      prefix = ""
    }

    expiration {
      days = local.cloudtrail_log_retention
    }

    status = "Enabled"
  }
}
