variable "cluster_id" {
    description = "EKS Cluster ID"
    type        = string
}
variable "vpc_id" {
    description = "VPC ID where the EKS cluster is deployed"
    type        = string
}
variable "aws_region" {
    description = "AWS region where the EKS cluster is deployed"
    type        = string
    default     = "us-east-1"
}
variable "cluster_endpoint" {
    description = "EKS Cluster endpoint"
    type        = string
}
variable "cluster_certificate_authority_data" {
    description = "Base64 encoded certificate authority data for the EKS cluster"
    type        = string
}