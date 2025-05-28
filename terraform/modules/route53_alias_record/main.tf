##################################################################################
### Resource for AWS Route 53 Alias Record                                     ###
##################################################################################

resource "aws_route53_record" "app_alias" {
  zone_id = var.zone_id
  name    = var.route53_zone_name
  type    = var.record_type
  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = var.evaluate_target_health
  }
}
