resource "aws_cloudwatch_log_group" "cloudtrail" {
  count = local.enable_cloudtrail ? 1 : 0

  name              = "${local.project_name}-cloudtrail"
  retention_in_days = local.cloudtrail_log_retention
  skip_destroy      = true
}

resource "aws_iam_role" "cloudtrail_cloudwatch_logs" {
  count = local.enable_cloudtrail ? 1 : 0

  name = "${local.project_name}-cloudtrail-cloudwatch-logs"
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

  depends_on = [
    aws_s3_bucket_policy.cloudtrail
  ]
}
