resource "aws_security_group" "eks" {
  name        = "${var.name}-eks-sg"
  description = "EKS security group"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow worker nodes to communicate with cluster"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidr_blocks
  }

  egress {
    description = "Allow outbound cluster traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.egress_cidr_blocks
  }

  tags = {
    Name = "${var.name}-eks-sg"
  }
}

