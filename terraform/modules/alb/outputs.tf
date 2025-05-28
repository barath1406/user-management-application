##################################################################################
### Outputs of ALB ###
##################################################################################
output "alb_arn" {
  description = "ARN of the ALB"
  value       = aws_lb.eks_alb.arn
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.eks_alb.dns_name
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.alb_tg.arn
}

output "https_listener_arn" {
  description = "ARN of the HTTPS listener"
  value       = aws_lb_listener.https_listener.arn
}

output "alb_zone_id" {
  description = "Zone ID of the ALB for Route 53 alias records"
  value       = aws_lb.eks_alb.zone_id
}