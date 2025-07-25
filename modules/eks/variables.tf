variable "name" {
  description = "Name prefix for EKS resources"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "cluster_role_arn" {
  description = "IAM role ARN for EKS control plane"
  type        = string
}

variable "node_role_arn" {
  description = "IAM role ARN for EKS node group"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs for EKS cluster"
  type        = list(string)
}

variable "cluster_role_dependency" {
  description = "Dependency to ensure IAM role is created before EKS"
  type        = any
}
