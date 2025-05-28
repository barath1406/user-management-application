##################################################################################
### Variables for Security Group Configuration                                 ###
##################################################################################

variable "sg_name" {
  description = "Name of the security group"
  type        = string
}

variable "sg_description" {
  description = "Description of the security group"
  type        = string
}


variable "vpc_id" {
  description = "ID of the VPC where the security group will be created"
  type        = string
}

variable "ingress_rules" {
  description = "List of ingress rules to create"
  type = list(object({
    description              = string
    ip_protocol              = string
    from_port                = optional(number)
    to_port                  = optional(number)
    cidr_ipv4                = optional(string)
    cidr_ipv6                = optional(string)
    source_security_group_id = optional(string)
  }))
  default = []
  validation {
    condition = alltrue([
      for rule in var.ingress_rules : (
        (rule.cidr_ipv4 != null && rule.cidr_ipv4 != "") ||
        (rule.cidr_ipv6 != null && rule.cidr_ipv6 != "") ||
        (rule.source_security_group_id != null && rule.source_security_group_id != "")
      )
    ])
    error_message = "Each ingress rule must specify at least one of cidr_ipv4, cidr_ipv6, or source_security_group_id."
  }
}

variable "egress_rules" {
  description = "List of egress rules to create"
  type = list(object({
    description                   = string
    ip_protocol                   = string
    from_port                     = optional(number)
    to_port                       = optional(number)
    cidr_ipv4                     = optional(string)
    destination_security_group_id = optional(string)
  }))
  default = []
  validation {
    condition = alltrue([
      for rule in var.egress_rules :
      (rule.cidr_ipv4 != null && rule.destination_security_group_id == null) ||
      (rule.cidr_ipv4 == null && rule.destination_security_group_id != null)
    ])
    error_message = "Each egress rule must specify either cidr_ipv4 OR destination_security_group_id, but not both."
  }
}

variable "tags" {
  description = "A map of tags to add to the security group"
  type        = map(string)
}
