output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_name" {
  description = "Endpoint for EKS control plane."
  value       = aws_eks_cluster.eks_cluster.name
}
output "security_group" {
  value = aws_security_group.security_group_eks_cluster.id
}
