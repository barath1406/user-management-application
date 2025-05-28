##################################################################################
###                              WAF Module Variables                          ###
##################################################################################

variable "whitelist_ips" {
  description = "List of IP addresses to whitelist"
  type        = list(string)
}

variable "ip_set_name" {
  description = "Name of the IP set for whitelisted IPs"
  type        = string
}

variable "ip_set_description" {
  description = "Description of the IP set for whitelisted IPs"
  type        = string
}

variable "waf_name" {
  description = "Name of the WAF Web ACL"
  type        = string
}

variable "waf_description" {
  description = "Description of the WAF Web ACL"
  type        = string
}

variable "default_action" {
  description = "Default action for WAF Web ACL (allow or block)"
  type        = string
}

variable "alb_arn" {
  description = "ARN of the ALB to associate with the WAF"
  type        = string
}

variable "metrics_enabled" {
  description = "Enable CloudWatch metrics for WAF"
  type        = bool
}

variable "sampled_requests" {
  description = "Enable sampled requests for WAF"
  type        = bool
}


variable "rule_whitelist_name" {
  description = "Name for the whitelist rule"
  type        = string
}

variable "rule_ip_rep_name" {
  description = "Name for the IP reputation rule"
  type        = string
}

variable "rule_anon_ip_name" {
  description = "Name for the anonymous IP rule"
  type        = string
}

variable "rule_sqli_name" {
  description = "Name for the SQL injection rule"
  type        = string
}


variable "metric_whitelist_name" {
  description = "Metric name for the whitelist rule"
  type        = string
}

variable "metric_ip_rep_name" {
  description = "Metric name for the IP reputation rule"
  type        = string
}

variable "metric_anon_ip_name" {
  description = "Metric name for the anonymous IP rule"
  type        = string
}

variable "metric_sqli_name" {
  description = "Metric name for the SQL injection rule"
  type        = string
}

variable "metric_waf_name" {
  description = "Main metric name for the WAF Web ACL"
  type        = string
}

variable "tags" {
  description = "Map of tags to apply to peering resources"
  type        = map(string)
}