# EKS Cluster Outputs
output "cluster_id" {
  description = "The name/id of the EKS cluster."
  value       = aws_eks_cluster.eks.id
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster."
  value       = aws_eks_cluster.eks.arn
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate authority data to communicate with the cluster."
  value       = aws_eks_cluster.eks.certificate_authority[0].data
}

output "cluster_endpoint" {
  description = "The endpoint for your EKS Kubernetes API."
  value       = aws_eks_cluster.eks.endpoint
}

output "cluster_version" {
  description = "The Kubernetes server version for the EKS cluster."
  value       = aws_eks_cluster.eks.version
}

output "cluster_oidc_issuer_url" {
  description = "The OIDC Issuer URL of the EKS cluster."
  value       = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

output "cluster_primary_security_group_id" {
  description = "The cluster primary security group ID created by the EKS cluster."
  value       = aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id
}

# EKS Node Group Outputs
output "node_group_id" {
  description = "EKS Managed Node Group ID"
  value       = aws_eks_node_group.node_group.id
}

output "node_group_arn" {
  description = "EKS Managed Node Group ARN"
  value       = aws_eks_node_group.node_group.arn
}

output "node_group_status" {
  description = "Current status of the Node Group"
  value       = aws_eks_node_group.node_group.status 
}

output "node_group_version" {
  description = "Kubernetes version for the Node Group"
  value       = aws_eks_node_group.node_group.version
}
