##################################################################################
### Resource for EKS Cluster                                                    ###
##################################################################################
resource "aws_eks_cluster" "barath_eks_cluster" {
  name                      = var.eks_cluster_name
  role_arn                  = var.eks_role_arn
  enabled_cluster_log_types = var.eks_enabled_log_types
  version                   = var.eks_cluster_version
  kubernetes_network_config {
    service_ipv4_cidr = var.eks_network_config
  }
  access_config {
    authentication_mode = var.authentication_mode
  }
  vpc_config {
    subnet_ids              = var.eks_subnet_ids
    endpoint_private_access = var.eks_endpoint_private_access
    endpoint_public_access  = var.eks_endpoint_public_access
    public_access_cidrs     = var.eks_public_access_cidrs
    security_group_ids      = var.eks_security_group_ids
  }

  tags = var.tags
}

##################################################################################
###                   EKS Access and IAM Policy Management                     ###
##################################################################################

# EKS User access entry configuration
resource "aws_eks_access_entry" "user_access" {
  cluster_name  = aws_eks_cluster.barath_eks_cluster.name
  principal_arn = "arn:aws:iam::${var.account_id}:user/${var.user_access}"
}

# EKS user admin policy association
resource "aws_eks_access_policy_association" "user_admin_policy" {
  cluster_name  = aws_eks_cluster.barath_eks_cluster.name
  policy_arn    = var.eks_admin_policy_arn
  principal_arn = "arn:aws:iam::${var.account_id}:user/${var.user_access}"
  access_scope {
    type = var.eks_type
  }
}

# EKS User access entry for role configuration
resource "aws_eks_access_entry" "user_access_role" {
  cluster_name  = aws_eks_cluster.barath_eks_cluster.name
  principal_arn = "arn:aws:iam::${var.account_id}:role/${var.bastion_host_iam_role}"
}

# EKS user admin policy association
resource "aws_eks_access_policy_association" "user_admin_role_policy" {
  cluster_name  = aws_eks_cluster.barath_eks_cluster.name
  policy_arn    = var.eks_admin_policy_arn
  principal_arn = "arn:aws:iam::${var.account_id}:role/${var.bastion_host_iam_role}"
  access_scope {
    type = var.eks_type
  }
}

##################################################################################
###                       OIDC Provider for EKS Cluster                        ###
##################################################################################

resource "aws_iam_openid_connect_provider" "oidc" {
  url             = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  client_id_list  = var.client_id_list
  thumbprint_list = var.thumbprint_list

  tags = merge(
    { Name = "${aws_eks_cluster.barath_eks_cluster.name}-oidc" }, var.tags
  )
}
