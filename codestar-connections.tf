resource "aws_codestarconnections_connection" "connections" {
  for_each      = local.codestar_connections
  name          = "${substr(local.project_name, 0, 31 - length(each.key))}-${each.key}"
  provider_type = each.value["provider_type"]
}
