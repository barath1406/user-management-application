##################################################################################
###                         ROUTE 53 ALIAS RECORD MODULE                       ### 
##################################################################################
module "route53_alias" {
  source                 = "../modules/route53_alias_record"
  zone_id                = data.aws_route53_zone.barath_r53.zone_id
  route53_zone_name      = var.route53_zone_name
  record_type            = var.record_type
  alb_dns_name           = module.alb.alb_dns_name
  alb_zone_id            = module.alb.alb_zone_id
  evaluate_target_health = var.evaluate_target_health
}