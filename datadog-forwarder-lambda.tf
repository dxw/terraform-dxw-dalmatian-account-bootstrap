resource "aws_kms_key" "datadog_forwarder" {
  count = local.enable_datadog_forwarder ? 1 : 0

  description             = "This key is used to encrypt the DataDog Forwarder Lambda logs (${local.project_name})"
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
      ${templatefile("${path.root}/policies/kms-key-policy-statements/cloudwatch-logs-allow.json.tpl",
      {
        log_group_arn = "arn:aws:logs:${local.aws_region}:${local.aws_account_id}:log-group:/aws/lambda/datadog-forwarder"
      }
  )}
      ]
      EOT
}
)
}

resource "aws_kms_alias" "datadog_forwarder" {
  count = local.enable_datadog_forwarder ? 1 : 0

  name          = "alias/${local.project_name}-datadog-forwarder-lambda"
  target_key_id = aws_kms_key.datadog_forwarder[0].key_id
}

resource "aws_cloudwatch_log_group" "datadog_forwarder_log_group" {
  count = local.enable_datadog_forwarder ? 1 : 0

  name              = "/aws/lambda/datadog-forwarder"
  kms_key_id        = aws_kms_key.datadog_forwarder[0].arn
  retention_in_days = local.datadog_forwarder_log_retention
}

resource "aws_iam_role" "datadog_forwarder" {
  count = local.enable_datadog_forwarder ? 1 : 0

  name        = "${local.project_name}-${substr(sha512("datadog-forwarder"), 0, 6)}"
  description = "${local.project_name}-datadog-forwarder"
  assume_role_policy = templatefile(
    "${path.root}/policies/assume-roles/service-principle-standard.json.tpl",
    { services = jsonencode(["lambda.amazonaws.com"]) }
  )
}

resource "aws_iam_policy" "datadog_forwarder_tags" {
  count = local.enable_datadog_forwarder ? 1 : 0

  name = "${local.project_name}-datadog-forwarder-tags"
  policy = templatefile(
    "${path.root}/policies/datadog-forwarder.json.tpl", {}
  )
}

resource "aws_iam_role_policy_attachment" "datadog_forwarder_tags" {
  count = local.enable_datadog_forwarder ? 1 : 0

  role       = aws_iam_role.datadog_forwarder[0].name
  policy_arn = aws_iam_policy.datadog_forwarder_tags[0].arn
}

resource "aws_iam_policy" "datadog_forwarder" {
  count = local.enable_datadog_forwarder ? 1 : 0

  name = "${local.project_name}-datadog-forwarder"
  policy = templatefile(
    "${path.root}/policies/lambda-default.json.tpl",
    {
      region        = local.aws_region
      account_id    = local.aws_account_id
      function_name = "datadog-forwarder"
    }
  )
}

resource "aws_iam_role_policy_attachment" "datadog_forwarder" {
  count = local.enable_datadog_forwarder ? 1 : 0

  role       = aws_iam_role.datadog_forwarder[0].name
  policy_arn = aws_iam_policy.datadog_forwarder[0].arn
}

resource "aws_iam_policy" "datadog_forwarder_s3_object_read" {
  count = local.enable_datadog_forwarder ? 1 : 0

  name = "${local.project_name}-datadog-forwarder-s3-object-read"
  policy = templatefile(
    "${path.root}/policies/s3-object-read.json.tpl",
    {
      bucket_arn : "*"
    }
  )
}

resource "aws_iam_role_policy_attachment" "datadog_forwarder_s3_object_read" {
  count = local.enable_datadog_forwarder ? 1 : 0

  role       = aws_iam_role.datadog_forwarder[0].name
  policy_arn = aws_iam_policy.datadog_forwarder_s3_object_read[0].arn
}

resource "aws_iam_policy" "datadog_forwarder_s3_object_rw" {
  count = local.enable_datadog_forwarder ? 1 : 0

  name = "${local.project_name}-datadog-forwarder-s3-object-rw"
  policy = templatefile(
    "${path.root}/policies/s3-object-rw.json.tpl",
    {
      bucket_arn : aws_s3_bucket.datadog_lambda[0].arn
    }
  )
}

resource "aws_iam_role_policy_attachment" "datadog_forwarder_s3_object_rw" {
  count = local.enable_datadog_forwarder ? 1 : 0

  role       = aws_iam_role.datadog_forwarder[0].name
  policy_arn = aws_iam_policy.datadog_forwarder_s3_object_rw[0].arn
}

resource "aws_iam_policy" "datadog_forwarder_kms_encrypt" {
  count = local.enable_datadog_forwarder ? 1 : 0

  name = "${local.project_name}-datadog-forwarder-kms-encrypt"
  policy = templatefile(
    "${path.root}/policies/kms-encrypt.json.tpl",
    {
      kms_key_arn : aws_kms_key.datadog_forwarder[0].arn
    }
  )
}

resource "aws_iam_role_policy_attachment" "datadog_forwarder_kms_encrypt" {
  count = local.enable_datadog_forwarder ? 1 : 0

  role       = aws_iam_role.datadog_forwarder[0].name
  policy_arn = aws_iam_policy.datadog_forwarder_kms_encrypt[0].arn
}

resource "aws_iam_policy" "datadog_forwarder_kms_encrypt_wildcard" {
  count = local.enable_datadog_forwarder ? 1 : 0

  name = "${local.project_name}-datadog-forwarder-kms-encrypt-all"
  policy = templatefile(
    "${path.root}/policies/kms-encrypt.json.tpl",
    {
      kms_key_arn : "arn:aws:kms:${local.aws_region}:${local.aws_account_id}:key/*"
    }
  )
}

resource "aws_iam_role_policy_attachment" "datadog_forwarder_kms_encrypt_wildcard" {
  count = local.enable_datadog_forwarder ? 1 : 0

  role       = aws_iam_role.datadog_forwarder[0].name
  policy_arn = aws_iam_policy.datadog_forwarder_kms_encrypt_wildcard[0].arn
}

resource "aws_iam_policy" "datadog_forwarder_secret" {
  count = local.enable_datadog_forwarder ? 1 : 0

  name = "${local.project_name}-datadog-forwarder-secrets-manager-get-secret-value"
  policy = templatefile(
    "${path.root}/policies/secrets-manager-get-secret-value.json.tpl",
    {
      secret_name_arns : jsonencode([
        aws_secretsmanager_secret.datadog_api_key[0].arn
      ])
    }
  )
}

resource "aws_iam_role_policy_attachment" "datadog_forwarder_secret" {
  count = local.enable_datadog_forwarder ? 1 : 0

  role       = aws_iam_role.datadog_forwarder[0].name
  policy_arn = aws_iam_policy.datadog_forwarder_secret[0].arn
}

data "archive_file" "datadog_forwarder" {
  count = local.enable_datadog_forwarder ? 1 : 0

  type        = "zip"
  source_dir  = "lambdas/aws-dd-forwarder-3.127.0"
  output_path = "lambdas/.zip-cache/aws-dd-forwarder-3.127.0.zip"
}

resource "aws_lambda_function" "datadog_service_log_forwarder" {
  count = local.enable_datadog_forwarder ? 1 : 0

  filename         = data.archive_file.datadog_forwarder[0].output_path
  function_name    = "datadog-forwarder"
  description      = "${local.project_name} DataDog AWS Service Log Forwarder"
  handler          = "lambda_function.datadog_forwarder"
  runtime          = "python3.11"
  role             = aws_iam_role.datadog_forwarder[0].arn
  source_code_hash = data.archive_file.datadog_forwarder[0].output_base64sha256
  memory_size      = 128
  package_type     = "Zip"
  timeout          = 900

  environment {
    variables = {
      DD_STORE_FAILED_EVENTS : local.datadog_forwarder_store_failed_events,
      DD_API_KEY_SECRET_ARN : aws_secretsmanager_secret.datadog_api_key[0].arn,
      DD_ENHANCED_METRICS : local.datadog_forwarder_enhanced_metrics,
      DD_S3_BUCKET_NAME : aws_s3_bucket.datadog_lambda[0].bucket,
      DD_SITE : local.datadog_site,
      DD_API_URL : local.datadog_api_url,
    }
  }

  tracing_config {
    mode = "Active"
  }

  depends_on = [
    aws_iam_role_policy_attachment.datadog_forwarder,
    aws_iam_role_policy_attachment.datadog_forwarder_s3_object_read,
    aws_iam_role_policy_attachment.datadog_forwarder_s3_object_rw,
    aws_iam_role_policy_attachment.datadog_forwarder_secret,
  ]
}

#tfsec:ignore:aws-ssm-secret-use-customer-key
resource "aws_secretsmanager_secret" "datadog_api_key" {
  count = local.enable_datadog_forwarder ? 1 : 0

  name = "${local.project_name_hash}/datadog/DD_API_KEY"
}

resource "aws_secretsmanager_secret_version" "datadog_api_key" {
  count = local.enable_datadog_forwarder ? 1 : 0

  secret_id     = aws_secretsmanager_secret.datadog_api_key[0].id
  secret_string = local.datadog_api_key
}

resource "datadog_integration_aws_lambda_arn" "datadog_forwarder_arn" {
  count = local.enable_datadog_forwarder ? 1 : 0

  account_id = local.aws_account_id
  lambda_arn = aws_lambda_function.datadog_service_log_forwarder[0].arn
}

resource "datadog_integration_aws_log_collection" "datadog_forwarder" {
  count = local.enable_datadog_forwarder ? 1 : 0

  account_id = local.aws_account_id
  services   = ["cloudfront", "waf", "elbv2", "s3"]
}

resource "aws_lambda_permission" "datadog_forwarder_allow_cloudwatch" {
  statement_id   = "AllowExecutionFromCloudWatch"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.datadog_service_log_forwarder[0].function_name
  principal      = "events.amazonaws.com"
  source_account = local.aws_account_id
}

resource "aws_lambda_permission" "datadog_forwarder_allow_sns" {
  statement_id   = "AllowExecutionFromSNS"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.datadog_service_log_forwarder[0].function_name
  principal      = "sns.amazonaws.com"
  source_account = local.aws_account_id
}

resource "aws_lambda_permission" "datadog_forwarder_allow_s3" {
  statement_id   = "AllowExecutionFromS3"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.datadog_service_log_forwarder[0].function_name
  principal      = "s3.amazonaws.com"
  source_account = local.aws_account_id
}
