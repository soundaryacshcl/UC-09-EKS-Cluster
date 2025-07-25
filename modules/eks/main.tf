
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "eks_kms" {
  statement {
    effect  = "Allow"
    actions = ["kms:*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    resources = ["*"]
  }
}

resource "aws_kms_key" "eks" {
  description             = "EKS secrets encryption"
  deletion_window_in_days = 2
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.eks_kms.json

}

resource "aws_kms_alias" "eks" {
  name          = "alias/${var.name}-eks"
  target_key_id = aws_kms_key.eks.id
}

resource "aws_eks_cluster" "eks" {
  name     = "${var.name}-eks"
  role_arn = var.cluster_role_arn

  vpc_config {
    subnet_ids              = var.public_subnets
    security_group_ids      = var.security_group_ids
    endpoint_public_access  = false
    endpoint_private_access = true
  }

  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = aws_kms_key.eks.arn
    }
  }

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  tags = {
    Name        = "${var.name}-eks-cluster"
    Environment = var.name
  }

  depends_on = [var.cluster_role_dependency]
}

resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${var.name}-node-group"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnets

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t3.medium"]
  disk_size      = 20
  capacity_type  = "ON_DEMAND"

  tags = {
    Name        = "${var.name}-node-group"
    Environment = var.name
  }

  depends_on = [aws_eks_cluster.eks]
}
