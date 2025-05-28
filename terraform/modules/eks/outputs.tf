##################################################################################
### Outputs for EKS Cluster                                                     ###
##################################################################################
output "cluster_id" {
  description = "The name/id of the EKS cluster."
  value       = aws_eks_cluster.barath_eks_cluster.id
}

output "cluster_name" {
  description = "The name/id of the EKS cluster."
  value       = var.eks_cluster_name
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster."
  value       = aws_eks_cluster.barath_eks_cluster.arn
}

output "cluster_endpoint" {
  description = "The endpoint of the EKS Cluster"
  value       = aws_eks_cluster.barath_eks_cluster.endpoint
}

output "cluster_ca" {
  description = "The CA of the EKS Cluster"
  value       = aws_eks_cluster.barath_eks_cluster.certificate_authority[0].data
}

output "oidc_issuer" {
  description = "The OIDC issuer for the cluster"
  value       = aws_eks_cluster.barath_eks_cluster.identity[0].oidc[0].issuer
}

output "cluster_auth" {
  description = "EKS cluster auth token"
  value       = data.aws_eks_cluster_auth.cluster_auth.token
}
