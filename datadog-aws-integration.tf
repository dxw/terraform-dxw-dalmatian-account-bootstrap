resource "aws_iam_role" "datadog_aws_integration" {
  count = local.enable_datadog_aws_integration ? 1 : 0

  name        = "${local.project_name_hash}-datadog-aws-integration"
  description = "${local.project_name}-datadog-aws-integration"
  assume_role_policy = templatefile(
    "${path.root}/policies/assume-roles/external-id.json.tpl", {
      iam_arns    = jsonencode(["arn:aws:iam::464622532012:root"]),
      external_id = datadog_integration_aws_external_id.aws[0].id
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

resource "datadog_integration_aws_external_id" "aws" {
  count = local.enable_datadog_aws_integration ? 1 : 0
}

resource "datadog_integration_aws_account" "aws" {
  count = local.enable_datadog_aws_integration ? 1 : 0

  aws_account_id = "234567890123"
  aws_partition  = "aws"
  aws_regions {
    include_only = [
      local.aws_region,
      "us-east-1"
    ]
  }

  auth_config {
    aws_auth_config_role {
      role_name   = "${local.project_name_hash}-datadog-aws-integration"
      external_id = datadog_integration_aws_external_id.aws[0].id
    }
  }

  logs_config {
    lambda_forwarder {}
  }

  metrics_config {
    namespace_filters {}
  }

  resources_config {}

  traces_config {
    xray_services {}
  }
}
