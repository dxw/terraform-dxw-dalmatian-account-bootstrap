resource "aws_iam_role" "custom" {
  for_each = local.custom_iam_roles

  name               = each.key
  description        = each.value["description"]
  assume_role_policy = each.value["assume_role_policy"]
}

resource "aws_iam_policy" "custom" {
  for_each = merge(flatten([
    for role_name, role in local.custom_iam_roles : {
      for policy_name, policy in role.policies :
      "${role_name}_${policy_name}" => {
        role_name   = role_name
        policy_name = policy_name
        policy      = policy
      }
    }
  ])...)

  name        = each.value["policy_name"]
  description = each.value["policy"]["description"]
  policy      = each.value["policy"]["policy"]
}

resource "aws_iam_role_policy_attachment" "custom" {
  for_each = aws_iam_policy.custom

  role       = aws_iam_role.custom[split("_", each.key)[0]].name
  policy_arn = each.value.arn
}
