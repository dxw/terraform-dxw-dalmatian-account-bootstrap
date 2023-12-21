resource "aws_cloudwatch_log_group" "cloudwatch_slack_alerts_lambda_log_group" {
  count = local.enable_cloudwatch_slack_alerts ? 1 : 0

  name              = "/aws/lambda/${local.project_name}-cloudwatch-to-slack"
  kms_key_id        = local.cloudwatch_slack_alerts_kms_encryption ? aws_kms_key.cloudwatch_slack_alerts[0].arn : null
  retention_in_days = local.cloudwatch_slack_alerts_log_retention
}

resource "aws_iam_role" "cloudwatch_slack_alerts_lambda" {
  count = local.enable_cloudwatch_slack_alerts ? 1 : 0

  name        = "${local.project_name}-${substr(sha512("cloudwatch-slack-alerts-lambda"), 0, 6)}"
  description = "${local.project_name}-cloudwatch-slack-alerts-lambda"
  assume_role_policy = templatefile(
    "${path.root}/policies/service-assume.json.tpl",
    { service = "lambda.amazonaws.com" }
  )
}

resource "aws_iam_policy" "cloudwatch_slack_alerts_logs_lambda" {
  count = local.enable_cloudwatch_slack_alerts ? 1 : 0

  name = "${local.project_name}-cloudwatch-slack-alerts-lambda"
  policy = templatefile(
    "${path.root}/policies/lambda-default.json.tpl",
    {
      region        = local.aws_region
      account_id    = local.aws_account_id
      function_name = "${local.project_name}-cloudwatch-slack-alerts"
    }
  )
}

resource "aws_iam_role_policy_attachment" "cloudwatch_slack_alerts_logs_lambda" {
  count = local.enable_cloudwatch_slack_alerts ? 1 : 0

  role       = aws_iam_role.cloudwatch_slack_alerts_lambda[0].name
  policy_arn = aws_iam_policy.cloudwatch_slack_alerts_logs_lambda[0].arn
}

data "archive_file" "cloudwatch_slack_alerts_lambda" {
  count = local.enable_cloudwatch_slack_alerts ? 1 : 0

  type        = "zip"
  source_dir  = "lambdas/cloudwatch-slack-alerts"
  output_path = "lambdas/.zip-cache/cloudwatch-slack-alerts.zip"
}

resource "aws_lambda_function" "cloudwatch_slack_alerts" {
  count = local.enable_cloudwatch_slack_alerts ? 1 : 0

  filename         = data.archive_file.cloudwatch_slack_alerts_lambda[0].output_path
  function_name    = "${local.project_name}-cloudwatch-slack-alerts"
  description      = "${local.project_name} CloudWatch Slack Alerts"
  handler          = "function.lambda_handler"
  runtime          = "python3.11"
  role             = aws_iam_role.cloudwatch_slack_alerts_lambda[0].arn
  source_code_hash = data.archive_file.cloudwatch_slack_alerts_lambda[0].output_base64sha256
  memory_size      = 128
  package_type     = "Zip"
  timeout          = 30

  environment {
    variables = {
      slackHookUrl = local.cloudwatch_slack_alerts_hook_url
      slackChannel = local.cloudwatch_slack_alerts_channel
    }
  }

  tracing_config {
    mode = "Active"
  }
}

resource "aws_lambda_permission" "cloudwatch_slack_alerts_sns" {
  count = local.enable_cloudwatch_slack_alerts ? 1 : 0

  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cloudwatch_slack_alerts[0].arn
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.cloudwatch_slack_alerts[0].arn
}
