##################################################################################
###                          Variables for IAM Policy                          ###
##################################################################################

# IAM Policy Basic Information
variable "policy_name" {
  description = "Name of the IAM policy"
  type        = string
}

variable "policy_description" {
  description = "Description for the IAM policy"
  type        = string
}

variable "policy_path" {
  description = "Path for the IAM policy"
  type        = string
}

variable "policy" {
  description = "IAM policy content"
  type        = string
}

variable "tags" {
  description = "A map of tags"
  type        = map(string)
}
