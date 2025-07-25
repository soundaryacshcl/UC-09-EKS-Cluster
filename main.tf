module "vpc" {
  source         = "./modules/vpc"
  name           = var.name
  vpc_cidr_block = var.vpc_cidr_block
}

module "iam" {
  source = "./modules/iam"
  name   = var.name
}

module "ecr" {
  source = "./modules/ecr"
  name   = var.name
}

module "security_group" {
  source = "./modules/security_group"
  name   = var.name
  vpc_id = module.vpc.vpc_id
}

module "eks" {
  source                  = "./modules/eks"
  name                    = var.name
  public_subnets          = module.vpc.public_subnets
  private_subnets         = module.vpc.private_subnets
  cluster_role_arn        = module.iam.eks_cluster_role_arn
  node_role_arn           = module.iam.eks_node_role_arn
  cluster_role_dependency = module.iam.eks_role_depends_on
  security_group_ids      = [module.security_group.eks_security_group_id]
}


