resource "aws_iam_role" "datadog_aws_integration" {
  count = local.enable_datadog_aws_integration ? 1 : 0

  name        = "${local.project_name_hash}-datadog-aws-integration"
  description = "${local.project_name}-datadog-aws-integration"
  assume_role_policy = templatefile(
    "${path.root}/policies/assume-roles/external-id.json.tpl", {
      iam_arns    = jsonencode(["arn:aws:iam::464622532012:root"]),
      external_id = datadog_integration_aws.aws[0].external_id
    }
  )
}

resource "aws_iam_policy" "datadog_aws_integration" {
  count = local.enable_datadog_aws_integration ? 1 : 0

  name = "${local.project_name}-datadog-aws-integration"
  policy = templatefile(
    "${path.root}/policies/datadog-integration.json.tpl", {}
  )
}

resource "aws_iam_role_policy_attachment" "datadog_aws_integration" {
  count = local.enable_datadog_aws_integration ? 1 : 0

  role       = aws_iam_role.datadog_aws_integration[0].name
  policy_arn = aws_iam_policy.datadog_aws_integration[0].arn
}

resource "aws_iam_policy" "datadog_aws_integration_resource_collection" {
  count = local.enable_datadog_aws_integration ? 1 : 0

  name = "${local.project_name}-datadog-aws-integration-resource-collection"
  policy = templatefile(
    "${path.root}/policies/datadog-integration-resource-collection.json.tpl", {}
  )
}

resource "aws_iam_role_policy_attachment" "datadog_aws_integration_resource_collection" {
  count = local.enable_datadog_aws_integration ? 1 : 0

  role       = aws_iam_role.datadog_aws_integration[0].name
  policy_arn = aws_iam_policy.datadog_aws_integration_resource_collection[0].arn
}

resource "aws_iam_role_policy_attachment" "datadog_aws_integration_security_audit" {
  count = local.enable_datadog_aws_integration ? 1 : 0

  role       = aws_iam_role.datadog_aws_integration[0].name
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

resource "datadog_integration_aws" "aws" {
  count = local.enable_datadog_aws_integration ? 1 : 0

  account_id       = local.aws_account_id
  role_name        = "${local.project_name_hash}-datadog-aws-integration"
  excluded_regions = local.datadog_resource_collection_excluded_regions
}
