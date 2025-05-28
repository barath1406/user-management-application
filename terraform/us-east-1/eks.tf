##################################################################################
###                            Module for EKS Cluster                          ### 
##################################################################################
module "eks" {
  source                      = "../modules/eks/"
  eks_cluster_name            = var.eks_cluster_name
  eks_role_arn                = data.aws_iam_role.eks_cluster_role.arn
  eks_subnet_ids              = module.vpc1.private_subnets
  eks_security_group_ids      = [module.eks_cluster_sg.security_group_id]
  eks_vpc_id                  = module.vpc1.vpc_id
  eks_worker_vpc_cidr         = [module.vpc1.vpc_cidr_block]
  user_access                 = var.user_access
  bastion_host_iam_role       = var.bastion_host_iam_role
  account_id                  = data.aws_caller_identity.current.account_id
  eks_cluster_version         = var.eks_cluster_version
  eks_enabled_log_types       = var.eks_enabled_log_types
  eks_endpoint_private_access = var.eks_endpoint_private_access
  eks_endpoint_public_access  = var.eks_endpoint_public_access
  eks_public_access_cidrs     = var.eks_public_access_cidrs
  eks_network_config          = var.eks_network_config
  eks_type                    = var.eks_type
  authentication_mode         = var.authentication_mode
  client_id_list              = var.client_id_list
  thumbprint_list             = var.thumbprint_list
  eks_admin_policy_arn        = var.eks_admin_policy_arn

  tags = var.tags
}

##################################################################################
###                    Module for EKS Cluster Security Group                   ### 
##################################################################################
module "eks_cluster_sg" {
  source         = "../modules/sg"
  sg_name        = var.eks_cluster_sg_name
  sg_description = var.eks_cluster_sg_description
  vpc_id         = module.vpc1.vpc_id
  ingress_rules  = var.eks_cluster_sg_ingress_rules
  egress_rules   = var.eks_cluster_sg_egress_rules

  tags = var.tags
}

##################################################################################
###                         Module for EKS Node Group                          ### 
##################################################################################
module "eks_nodegroup" {
  source                              = "../modules/eks/node-groups/"
  eks_node_group_eks_cluster_name     = module.eks.cluster_name
  eks_node_group_name                 = var.eks_node_group_name
  eks_node_role_arn                   = data.aws_iam_role.eks_nodegroup_role.arn
  eks_node_group_subnet_ids           = module.vpc1.private_subnets
  eks_node_group_desired_size         = var.eks_node_group_desired_size
  eks_node_group_max_size             = var.eks_node_group_max_size
  eks_node_group_min_size             = var.eks_node_group_min_size
  eks_node_group_capacity_type        = var.eks_node_group_capacity_type
  eks_node_group_instance_type        = var.eks_node_group_instance_type
  eks_node_group_disk_size            = var.eks_node_group_disk_size
  eks_node_group_ami_id               = data.aws_ssm_parameter.node_ami.value
  ami_type                            = var.ami_type
  resource_type                       = var.resource_type
  eks_node_key_name                   = var.eks_node_key_name
  eks_node_group_security_group_ids   = [module.eks_nodegroup_sg.security_group_id]
  eks_node_group_launch_template_name = var.eks_node_group_launch_template_name
  device_name                         = var.device_name
  delete_on_termination               = var.delete_on_termination
  volume_size                         = var.volume_size
  volume_type                         = var.volume_type
  http_put_response_hop_limit         = var.http_put_response_hop_limit
  http_endpoint                       = var.http_endpoint
  http_tokens                         = var.http_tokens
  eks_node_group_labels               = var.eks_node_group_labels
  eks_node_group_auth_base64          = module.eks.cluster_ca
  eks_node_group_eks_endpoint         = module.eks.cluster_endpoint
  eks_cluster_name                    = module.eks.cluster_name
  eks_region                          = data.aws_region.current.name

  eks_node_group_tags = merge(var.tags, var.eks_patch_group_tags, { Name = var.eks_node_name })

  depends_on = [module.eks]
}

##################################################################################
###                  Module for EKS Node Group Security Group                  ### 
##################################################################################
module "eks_nodegroup_sg" {
  source         = "../modules/sg"
  sg_name        = var.eks_nodegroup_sg_name
  sg_description = var.eks_nodegroup_sg_description
  vpc_id         = module.vpc1.vpc_id
  ingress_rules  = var.eks_nodegroup_sg_ingress_rules
  egress_rules   = var.eks_nodegroup_sg_egress_rules

  tags = var.tags
}