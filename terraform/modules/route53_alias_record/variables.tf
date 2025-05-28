##################################################################################
### Route 53 Alias Record Configuration Variables                               ###
##################################################################################
variable "zone_id" {
  description = "Zone Id of the Route53 hosted zone"
  type        = string
}

variable "route53_zone_name" {
  description = "Fully qualified domain name to create (e.g., app.example.com)"
  type        = string
}

variable "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  type        = string
}

variable "record_type" {
  description = "Route 53 record type"
  type        = string
}

variable "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  type        = string
}

variable "evaluate_target_health" {
  description = "Indicates whether the target health is enabled"
  type        = bool
}
