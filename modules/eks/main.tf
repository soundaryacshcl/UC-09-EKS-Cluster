resource "aws_eks_cluster" "eks" {
  name     = "${var.name}-eks"
  role_arn = var.cluster_role_arn

  vpc_config {
    subnet_ids         = var.public_subnets
    security_group_ids = var.security_group_ids
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
