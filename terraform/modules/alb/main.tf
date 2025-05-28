##################################################################################
###                       Data Resource for EKS Nodes                          ###
##################################################################################
data "aws_autoscaling_groups" "eks_nodes" {
  filter {
    name   = "tag:kubernetes.io/cluster/${var.eks_cluster_name}"
    values = ["owned"]
  }
}

data "aws_elb_service_account" "main" {}

locals {
  asg_name = length(data.aws_autoscaling_groups.eks_nodes.names) > 0 ? data.aws_autoscaling_groups.eks_nodes.names[0] : ""
}

##################################################################################
###                               Resource for ALB                             ###
##################################################################################
resource "aws_lb" "eks_alb" {
  name                       = "${var.eks_cluster_name}-alb"
  internal                   = var.internal_alb
  load_balancer_type         = "application"
  security_groups            = [var.security_group_id]
  subnets                    = var.public_subnets
  enable_deletion_protection = var.enable_deletion_protection

  tags = merge(var.tags, {
    Name                                            = "${var.eks_cluster_name}-alb"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
  })
}

##################################################################################
###                              Resource for ALB TG                           ###
##################################################################################
resource "aws_lb_target_group" "alb_tg" {
  name     = "${var.eks_cluster_name}-alb-tg"
  port     = var.target_group_port
  protocol = var.https_protocol
  vpc_id   = var.vpc_id
  health_check {
    enabled             = true
    interval            = var.health_check_interval
    path                = var.health_check_path
    port                = var.health_check_port
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    timeout             = var.health_check_timeout
    matcher             = var.health_check_matcher
  }

  tags = merge(var.tags, {
    Name = "${var.eks_cluster_name}-alb-tg"
  })
}

##################################################################################
###                          Resource for ALB Listener                         ###
##################################################################################
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.eks_alb.arn
  port              = var.https_port
  protocol          = var.https_protocol
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.acm_certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  count = local.asg_name != "" ? 1 : 0

  autoscaling_group_name = local.asg_name
  lb_target_group_arn    = aws_lb_target_group.alb_tg.arn
}