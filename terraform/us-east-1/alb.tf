##################################################################################
###                     Module for ALB EC2 Security Group                      ###
##################################################################################
module "alb_security_group" {
  source         = "../modules/sg"
  sg_name        = "${var.eks_cluster_name}-alb-sg"
  sg_description = var.alb_sg_description
  vpc_id         = module.vpc1.vpc_id
  ingress_rules  = var.alb_sg_ingress_rules
  egress_rules   = var.alb_sg_egress_rules

  tags = var.tags
}

##################################################################################
###                          Module for ALB                                    ###
##################################################################################
module "alb" {
  source                           = "../modules/alb"
  eks_cluster_name                 = var.eks_cluster_name
  vpc_id                           = module.vpc1.vpc_id
  public_subnets                   = module.vpc1.public_subnets
  security_group_id                = module.alb_security_group.security_group_id
  enable_deletion_protection       = var.enable_alb_deletion_protection
  acm_certificate_arn              = var.acm_certificate_arn
  health_check_path                = var.health_check_path
  health_check_port                = var.health_check_port
  health_check_interval            = var.health_check_interval
  health_check_timeout             = var.health_check_timeout
  health_check_healthy_threshold   = var.health_check_healthy_threshold
  health_check_unhealthy_threshold = var.health_check_unhealthy_threshold
  health_check_matcher             = var.health_check_matcher
  target_group_port                = var.target_group_port
  ssl_policy                       = var.ssl_policy
  https_protocol                   = var.https_protocol
  https_port                       = var.https_port
  internal_alb                     = var.internal_alb

  tags = var.tags
}