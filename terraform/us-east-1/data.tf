##################################################################################
###                  Data Definitions - General AWS Information                ### 
##################################################################################

data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

##################################################################################
###     Fetch the latest EKS Optimized AMI ID using SSM Parameter Store        ### 
##################################################################################

data "aws_ssm_parameter" "node_ami" {
  name = var.eks_node_ami
}

##################################################################################
###           Data Source: Fetching EKS Optimized AMI using Filters            ### 
##################################################################################

data "aws_ami" "eks_optimized" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.eks_cluster_version}-v*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

##################################################################################
###      Data Source: Fetching Latest Amazon Linux AMI for Bastion Host        ### 
##################################################################################

data "aws_ami" "bastion" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

##################################################################################
###               Data Sources: IAM Roles and Instance Profiles                ### 
##################################################################################

data "aws_iam_role" "lambda_role" {
  name = var.lambda_iam_role_name
}

data "aws_iam_role" "eks_cluster_role" {
  name = var.eks_cluster_iam_role
}

data "aws_iam_role" "eks_nodegroup_role" {
  name = var.eks_nodegroup_iam_role
}

data "aws_iam_role" "bastion_host_role" {
  name = var.bastion_host_iam_role
}

data "aws_iam_instance_profile" "bastion_host_instance_profile" {
  name = data.aws_iam_role.bastion_host_role.name
}

data "aws_iam_role" "rds_monitoring_role" {
  name = var.rds_monitoring_role
}

data "aws_iam_policy" "irsa_user_portal_policy" {
  name        = var.irsa_user_portal_policy_name
  path_prefix = var.eks_cluster_iam_role_path
}

##################################################################################
###              Data Sources: Application and Networking Resources            ### 
##################################################################################

data "aws_lb" "app_alb" {
  name       = var.user_portal_alb_name
  depends_on = [module.alb]
}

##################################################################################
###                      Data Sources: Route53 Hosted Zone                     ### 
##################################################################################

data "aws_route53_zone" "barath_r53" {
  name         = var.route53_zone_name
  private_zone = false
}

##################################################################################
###                Data Block: Create Lambda Deployment Package                ### 
##################################################################################

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = var.lambda_source_path
  output_path = "${path.module}/lambda_function_payload.zip"
}