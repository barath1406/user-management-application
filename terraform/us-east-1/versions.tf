##################################################################################
### Terraform Configuration - Required Versions ###
##################################################################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.90"
    }
  }
  required_version = "1.9.8"
}
