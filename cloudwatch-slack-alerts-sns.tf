resource "aws_sns_topic" "cloudwatch_slack_alerts" {
  count = local.enable_cloudwatch_slack_alerts ? 1 : 0

  name = "${local.project_name}-cloudwatch-slack-alerts"
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
