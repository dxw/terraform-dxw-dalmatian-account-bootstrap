resource "aws_kms_key" "cloudtrail_cloudwatch_logs" {
  count = local.cloudtrail_kms_encryption ? 1 : 0

  description             = "This key is used to encrypt data in SNS for the CloudTrail CloudWatch Logs (${local.project_name})"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  policy = templatefile(
    "${path.root}/policies/kms-key-policy.json.tpl",
    {
      statement = <<EOT
      [
      ${templatefile("${path.root}/policies/kms-key-policy-statements/root-allow-all.json.tpl",
      {
        aws_account_id = local.aws_account_id
      }
      )},
      ${templatefile("${path.root}/policies/kms-key-policy-statements/cloudtrail-allow-encrypt.json.tpl",
      {
        cloudtrail_arn = "arn:aws:cloudtrail:${local.aws_region}:${local.aws_account_id}:trail/${local.project_name}"
        aws_account_id = local.aws_account_id
      }
      )},
      ${templatefile("${path.root}/policies/kms-key-policy-statements/service-allow-decrypt.json.tpl",
      {
        services = jsonencode(["cloudtrail.amazonaws.com"])
      }
      )},
      ${templatefile("${path.root}/policies/kms-key-policy-statements/service-describe-key.json.tpl",
      {
        services   = jsonencode(["cloudtrail.amazonaws.com"])
        key_arn    = "*"
        source_arn = "arn:aws:cloudtrail:${local.aws_region}:${local.aws_account_id}:trail/${local.project_name}"
      }
      )},
      ${templatefile("${path.root}/policies/kms-key-policy-statements/cloudwatch-logs-allow.json.tpl",
      {
        log_group_arn = "arn:aws:logs:${local.aws_region}:${local.aws_account_id}:log-group:${local.project_name}-cloudtrail"
      }
  )}
      ]
      EOT
}
)
}

resource "aws_kms_alias" "cloudtrail_cloudwatch_logs" {
  count = local.cloudtrail_kms_encryption ? 1 : 0

  name          = "alias/${local.project_name}-cloudtrail-cloudwatch-logs"
  target_key_id = aws_kms_key.cloudtrail_cloudwatch_logs[0].key_id
}

resource "aws_cloudwatch_log_group" "cloudtrail" {
  count = local.enable_cloudtrail ? 1 : 0

  name              = "${local.project_name}-cloudtrail"
  retention_in_days = local.cloudtrail_log_retention
  kms_key_id        = local.cloudtrail_kms_encryption ? aws_kms_key.cloudtrail_cloudwatch_logs[0].arn : null
  skip_destroy      = true
}

resource "aws_iam_role" "cloudtrail_cloudwatch_logs" {
  count = local.enable_cloudtrail ? 1 : 0

  name        = "${local.project_name}-${substr(sha512("cloudtrail-cloudwatch-logs"), 0, 6)}"
  description = "${local.project_name}-cloudtrail-cloudwatch-logs"
  assume_role_policy = templatefile(
    "${path.root}/policies/service-assume.json.tpl",
    { service = "cloudtrail.amazonaws.com" }
  )
}

resource "aws_iam_policy" "cloudtrail_cloudwatch_logs" {
  count = local.enable_cloudtrail ? 1 : 0

  name = "${local.project_name}-cloudtrail-cloudwatch-logs"
  policy = templatefile(
    "${path.root}/policies/cloudtrail-cloudwatch-logs.json.tpl",
    {
      cloudwatch_log_group_arn = aws_cloudwatch_log_group.cloudtrail[0].arn,
      account_id               = local.aws_account_id
      region                   = local.aws_region
    }
  )
}

resource "aws_iam_role_policy_attachment" "cloudtrail_cloudwatch_logs" {
  role       = aws_iam_role.cloudtrail_cloudwatch_logs[0].name
  policy_arn = aws_iam_policy.cloudtrail_cloudwatch_logs[0].arn
}

resource "aws_cloudtrail" "cloudtrail" {
  count = local.enable_cloudtrail ? 1 : 0

  name                          = local.project_name
  s3_bucket_name                = aws_s3_bucket.cloudtrail[0].id
  s3_key_prefix                 = local.cloudtrail_log_prefix != "" ? local.cloudtrail_log_prefix : null
  include_global_service_events = true
  is_multi_region_trail         = true
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_cloudwatch_logs[0].arn
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail[0].arn}:*"
  enable_log_file_validation    = true
  kms_key_id                    = local.cloudtrail_kms_encryption ? aws_kms_key.cloudtrail_cloudwatch_logs[0].arn : null

  depends_on = [
    aws_s3_bucket_policy.cloudtrail
  ]
}
