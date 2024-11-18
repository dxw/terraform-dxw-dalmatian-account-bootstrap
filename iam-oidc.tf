resource "aws_iam_openid_connect_provider" "custom" {
  for_each = local.openid_connect_providers

  url             = "https://${each.value["host"]}"
  client_id_list  = each.value["client_id_list"]
  thumbprint_list = [data.external.oidc_certificate_thumbprint[each.key].result.thumbprint]
}
