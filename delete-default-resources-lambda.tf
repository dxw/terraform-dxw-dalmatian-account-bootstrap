resource "aws_kms_key" "delete_default_resources_lambda" {
  count = local.delete_default_resources_lambda_kms_encryption ? 1 : 0

  description             = "This key is used to encrypt the Delete Default Resources Lambda logs (${local.project_name})"
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
        log_group_arn = "arn:aws:logs:${local.aws_region}:${local.aws_account_id}:log-group:/aws/lambda/${local.project_name}-delete-default-resources"
      }
  )}
      ]
      EOT
}
)
}

resource "aws_kms_alias" "delete_default_resources_lambda" {
  count = local.delete_default_resources_lambda_kms_encryption ? 1 : 0

  name          = "alias/${local.project_name}-delete-default-resources-lambda"
  target_key_id = aws_kms_key.delete_default_resources_lambda[0].key_id
}

resource "aws_cloudwatch_log_group" "delete_default_resources_lambda_log_group" {
  count = local.enable_delete_default_resources ? 1 : 0

  name              = "/aws/lambda/${local.project_name}-delete-default-resources"
  kms_key_id        = local.delete_default_resources_lambda_kms_encryption ? aws_kms_key.delete_default_resources_lambda[0].arn : null
  retention_in_days = local.delete_default_resources_log_retention
}

resource "aws_iam_role" "delete_default_resources_lambda" {
  count = local.enable_delete_default_resources ? 1 : 0

  name = "${local.project_name}-delete-default-resources-lambda"
  assume_role_policy = templatefile(
    "${path.root}/policies/service-assume.json.tpl",
    { service = "lambda.amazonaws.com" }
  )
}

resource "aws_iam_policy" "delete_default_resources_lambda" {
  count = local.enable_delete_default_resources ? 1 : 0

  name = "${local.project_name}-delete-default-resources-lambda"
  policy = templatefile(
    "${path.root}/policies/lambda-default.json.tpl",
    {
      region        = local.aws_region
      account_id    = local.aws_account_id
      function_name = "${local.project_name}-delete-default-resources"
    }
  )
}

resource "aws_iam_role_policy_attachment" "delete_default_resources_lambda" {
  count = local.enable_delete_default_resources ? 1 : 0

  role       = aws_iam_role.delete_default_resources_lambda[0].name
  policy_arn = aws_iam_policy.delete_default_resources_lambda[0].arn
}

resource "aws_iam_policy" "delete_default_resources_vpc_delete_lambda" {
  count = local.enable_delete_default_resources ? 1 : 0

  name = "${local.project_name}-delete-default-resources-vpc-delete-lambda"
  policy = templatefile(
    "${path.root}/policies/vpc-delete.json.tpl", {}
  )
}

resource "aws_iam_role_policy_attachment" "delete_default_resources_vpc_delete_lambda" {
  count = local.enable_delete_default_resources ? 1 : 0

  role       = aws_iam_role.delete_default_resources_lambda[0].name
  policy_arn = aws_iam_policy.delete_default_resources_vpc_delete_lambda[0].arn
}

data "archive_file" "delete_default_resources_lambda" {
  count = local.enable_delete_default_resources ? 1 : 0

  type        = "zip"
  source_dir  = "lambdas/delete-default-resources"
  output_path = "lambdas/.zip-cache/delete-default-resources.zip"
}

resource "aws_lambda_function" "delete_default_resources" {
  count = local.enable_delete_default_resources ? 1 : 0

  filename         = data.archive_file.delete_default_resources_lambda[0].output_path
  function_name    = "${local.project_name}-delete-default-resources"
  description      = "${local.project_name} Delete Default Resources"
  handler          = "function.lambda_handler"
  runtime          = "python3.11"
  role             = aws_iam_role.delete_default_resources_lambda[0].arn
  source_code_hash = data.archive_file.delete_default_resources_lambda[0].output_base64sha256
  memory_size      = 128
  package_type     = "Zip"
  timeout          = 900

  tracing_config {
    mode = "Active"
  }
}
