resource "aws_sns_topic" "aws_config" {
  count = local.enable_aws_config ? 1 : 0

  name = "${local.project_name}-aws-config"
}

resource "aws_sns_topic_policy" "aws_config" {
  count = local.enable_aws_config ? 1 : 0

  arn = aws_sns_topic.aws_config[0].arn
  policy = templatefile(
    "${path.root}/policies/sns-aws-config.json.tpl",
    {
      sns_arn = aws_sns_topic.aws_config[0].arn
    }
  )
}

resource "aws_sns_topic_subscription" "sns-topic" {
  provider  = aws.sns2sqs
  topic_arn = aws_sns_topic.sns-topic.arn
  protocol  = "email"
  endpoint  = aws_sqs_queue.sqs-queue.arn
}
