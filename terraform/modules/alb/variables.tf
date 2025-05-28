##################################################################################
###                             Variables for ALB                              ###
##################################################################################
variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "security_group_id" {
  description = "ID of the security group for the ALB"
  type        = string
}

variable "enable_deletion_protection" {
  description = "Whether to enable deletion protection for the ALB"
  type        = bool
  default     = false
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate to use for HTTPS"
  type        = string
}

variable "health_check_path" {
  description = "Path for ALB health check"
  type        = string
}

variable "health_check_port" {
  description = "Port for ALB health check"
  type        = string
}

variable "health_check_interval" {
  description = "Interval for ALB health check"
  type        = number
}

variable "health_check_timeout" {
  description = "Timeout for ALB health check"
  type        = number
}

variable "health_check_healthy_threshold" {
  description = "Healthy threshold for ALB health check"
  type        = number
}

variable "health_check_unhealthy_threshold" {
  description = "Unhealthy threshold for ALB health check"
  type        = number
}

variable "health_check_matcher" {
  description = "HTTP codes to use when checking for a successful response from a target"
  type        = string
}

variable "target_group_port" {
  description = "Port for the ALB target group"
  type        = number
}

variable "https_protocol" {
  description = "Protocol for the ALB target group"
  type        = string
}

variable "https_port" {
  description = "HTTPS Port for the ALB target group"
  type        = number
}

variable "internal_alb" {
  description = "Flag for Internal ALB"
  type        = bool
}

variable "ssl_policy" {
  description = "SSL policy for HTTPS listener"
  type        = string
}

variable "tags" {
  description = "Additional tags to add to the resources"
  type        = map(string)
  default     = {}
}