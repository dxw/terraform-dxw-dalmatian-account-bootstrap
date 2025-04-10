data "aws_caller_identity" "current" {}

data "external" "oidc_certificate_thumbprint" {
  for_each = local.openid_connect_providers

  program = ["/bin/bash", "${path.root}/external-data-scripts/get-certificate-thumbprint.sh"]

  query = {
    host = each.value["host"]
  }
}
