resource "aws_kms_key" "cloudwatch_opsgenie_alerts_sns" {
  count = local.cloudwatch_opsgenie_alerts_sns_kms_encryption ? 1 : 0

  description             = "This key is used to encrypt data in SNS for the CloudWatch Opsgenie Alerts (${local.project_name})"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  policy = templatefile(
    "${path.module}/policies/kms-key-policy-sns-topic.json.tpl",
    {
      services      = jsonencode(["cloudwatch.amazonaws.com"]),
      sns_topic_arn = "arn:aws:sns:${local.aws_region}:${local.aws_account_id}:${local.project_name}-cloudwatch-opsgenie-alerts"
    }
  )
}

resource "aws_kms_alias" "cloudwatch_opsgenie_alerts_sns" {
  count = local.cloudwatch_opsgenie_alerts_sns_kms_encryption ? 1 : 0

  name          = "alias/${local.project_name}-cloudwatch-opsgenie-alerts-sns"
  target_key_id = aws_kms_key.cloudwatch_opsgenie_alerts_sns[0].key_id
}

resource "aws_sns_topic" "cloudwatch_opsgenie_alerts" {
  count = local.enable_cloudwatch_opsgenie_alerts ? 1 : 0

  name              = "${local.project_name}-cloudwatch-opsgenie-alerts"
  kms_master_key_id = local.cloudwatch_opsgenie_alerts_sns_kms_encryption ? aws_kms_alias.cloudwatch_opsgenie_alerts_sns[0].name : null
}

resource "aws_kms_key" "cloudwatch_opsgenie_alerts_sns_us_east_1" {
  count = local.cloudwatch_opsgenie_alerts_sns_kms_encryption ? 1 : 0

  provider = aws.useast1

  description             = "This key is used to encrypt data in SNS for the CloudWatch Opsgenie Alerts (${local.project_name})"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  policy = templatefile(
    "${path.module}/policies/kms-key-policy-sns-topic.json.tpl",
    {
      services      = jsonencode(["cloudwatch.amazonaws.com"]),
      sns_topic_arn = "arn:aws:sns:us-east-1:${local.aws_account_id}:${local.project_name}-cloudwatch-opsgenie-alerts"
    }
  )
}

resource "aws_kms_alias" "cloudwatch_opsgenie_alerts_sns_us_east_1" {
  count = local.cloudwatch_opsgenie_alerts_sns_kms_encryption ? 1 : 0

  provider = aws.useast1

  name          = "alias/${local.project_name}-cloudwatch-opsgenie-alerts-sns"
  target_key_id = aws_kms_key.cloudwatch_opsgenie_alerts_sns_us_east_1[0].key_id
}


resource "aws_sns_topic" "cloudwatch_opsgenie_alerts_us_east_1" {
  count = local.enable_cloudwatch_opsgenie_alerts ? 1 : 0

  provider = aws.useast1

  name              = "${local.project_name}-cloudwatch-opsgenie-alerts"
  kms_master_key_id = local.cloudwatch_opsgenie_alerts_sns_kms_encryption ? aws_kms_alias.cloudwatch_opsgenie_alerts_sns_us_east_1[0].name : null
}

resource "aws_sns_topic_policy" "sns_cloudwatch_opsgenie_alerts" {
  count = local.enable_cloudwatch_opsgenie_alerts ? 1 : 0

  arn = aws_sns_topic.cloudwatch_opsgenie_alerts[0].arn
  policy = templatefile(
    "${path.root}/policies/sns-events-policy.json.tpl",
    {
      sns_arn        = aws_sns_topic.cloudwatch_opsgenie_alerts[0].arn
      aws_account_id = local.aws_account_id
    }
  )
}

resource "aws_sns_topic_policy" "sns_cloudwatch_opsgenie_alerts_us_east_1" {
  count = local.enable_cloudwatch_opsgenie_alerts ? 1 : 0

  provider = aws.useast1

  arn = aws_sns_topic.cloudwatch_opsgenie_alerts_us_east_1[0].arn
  policy = templatefile(
    "${path.root}/policies/sns-events-policy.json.tpl",
    {
      sns_arn        = aws_sns_topic.cloudwatch_opsgenie_alerts_us_east_1[0].arn
      aws_account_id = local.aws_account_id
    }
  )
}

resource "aws_sns_topic_subscription" "cloudwatch_opsgenie_alerts_subscription" {
  count = local.enable_cloudwatch_opsgenie_alerts ? 1 : 0

  topic_arn                       = aws_sns_topic.cloudwatch_opsgenie_alerts[0].arn
  protocol                        = "https"
  endpoint                        = local.cloudwatch_opsgenie_alerts_sns_endpoint
  endpoint_auto_confirms          = true
  confirmation_timeout_in_minutes = 10
}

resource "aws_sns_topic_subscription" "cloudwatch_opsgenie_alerts_subscription_us_east_1" {
  count = local.enable_cloudwatch_opsgenie_alerts ? 1 : 0

  provider = aws.useast1

  topic_arn                       = aws_sns_topic.cloudwatch_opsgenie_alerts_us_east_1[0].arn
  protocol                        = "https"
  endpoint                        = local.cloudwatch_opsgenie_alerts_sns_endpoint
  endpoint_auto_confirms          = true
  confirmation_timeout_in_minutes = 10
}
