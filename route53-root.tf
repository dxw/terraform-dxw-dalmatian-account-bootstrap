resource "aws_route53_zone" "root" {
  count = local.enable_route53_root_hosted_zone ? 1 : 0

  name = local.route53_root_hosted_zone_domain_name
}
