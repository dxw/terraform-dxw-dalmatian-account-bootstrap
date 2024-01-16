resource "aws_kms_key" "cloudwatch_slack_alerts" {
  count = local.cloudwatch_slack_alerts_kms_encryption ? 1 : 0

  description             = "This key is used to encrypt data in SNS for the CloudWatch Slack Alerts and logs (${local.project_name})"
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
      ${templatefile("${path.root}/policies/kms-key-policy-statements/cloudwatch-sns-allow-encrypt.json.tpl",
      {
        sns_topic_arn = "arn:aws:sns:${local.aws_region}:${local.aws_account_id}:${local.project_name}-cloudwatch-slack-alerts"
      }
      )},
      ${templatefile("${path.root}/policies/kms-key-policy-statements/cloudwatch-logs-allow.json.tpl",
      {
        log_group_arn = "arn:aws:logs:${local.aws_region}:${local.aws_account_id}:log-group:/aws/lambda/${local.project_name}-cloudwatch-to-slack"
      }
      )},
      ${templatefile("${path.root}/policies/kms-key-policy-statements/service-allow-encrypt.json.tpl",
      {
        services = jsonencode(["events.amazonaws.com"])
      }
  )}
      ]
      EOT
}
)
}

resource "aws_kms_alias" "cloudwatch_slack_alerts" {
  count = local.cloudwatch_slack_alerts_kms_encryption ? 1 : 0

  name          = "alias/${local.project_name}-cloudwatch-slack-alerts-sns"
  target_key_id = aws_kms_key.cloudwatch_slack_alerts[0].key_id
}

resource "aws_sns_topic" "cloudwatch_slack_alerts" {
  count = local.enable_cloudwatch_slack_alerts ? 1 : 0

  name              = "${local.project_name}-cloudwatch-slack-alerts"
  kms_master_key_id = local.cloudwatch_slack_alerts_kms_encryption ? aws_kms_alias.cloudwatch_slack_alerts[0].name : null
}

resource "aws_sns_topic_policy" "sns_cloudwatch_slack_alerts" {
  count = local.enable_cloudwatch_slack_alerts ? 1 : 0

  arn = aws_sns_topic.cloudwatch_slack_alerts[0].arn
  policy = templatefile(
    "${path.root}/policies/sns-events-policy.json.tpl",
    {
      sns_arn        = aws_sns_topic.cloudwatch_slack_alerts[0].arn
      aws_account_id = local.aws_account_id
    }
  )
}

resource "aws_sns_topic_subscription" "cloudwatch_slack_alerts_lambda_subscription" {
  count = local.enable_cloudwatch_slack_alerts ? 1 : 0

  topic_arn = aws_sns_topic.cloudwatch_slack_alerts[0].arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.cloudwatch_slack_alerts[0].arn
}
