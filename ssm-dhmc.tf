resource "aws_iam_role" "ssm_dhmc" {
  count = local.enable_ssm_dhmc ? 1 : 0

  name = "${local.project_name}-ssm-dhmc"
  assume_role_policy = templatefile(
    "${path.root}/policies/assume-roles/service-principle-standard.json.tpl",
    { services = jsonencode(["ssm.amazonaws.com"]) }
  )
}

resource "aws_iam_policy" "ssm_dhmc" {
  count = local.enable_ssm_dhmc ? 1 : 0

  name   = "${local.project_name}-ssm-dhmc"
  policy = templatefile("${path.root}/policies/ssm-dhmc.json.tpl", {})
}

resource "aws_iam_role_policy_attachment" "ssm_dhmc" {
  count = local.enable_ssm_dhmc ? 1 : 0

  role       = aws_iam_role.ssm_dhmc[0].name
  policy_arn = aws_iam_policy.ssm_dhmc[0].arn
}

resource "aws_ssm_service_setting" "ssm_dhmc" {
  count = local.enable_ssm_dhmc ? 1 : 0

  setting_id    = "arn:aws:ssm:${local.aws_region}:${local.aws_account_id}:servicesetting/ssm/managed-instance/default-ec2-instance-management-role"
  setting_value = aws_iam_role.ssm_dhmc[0].name
}
