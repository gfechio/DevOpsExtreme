terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "devops-extreme-hashicorp"
    workspaces {
      name = "devops-extreme"
    }
  }
}

provider aws {
  region                  = var.aws_region
  profile                 = var.profile
}

provider "http" {}

module "vpc" {
  source = "../modules/vpc"
}

module "network" {
  source             = "../modules/network"
  vpc_id             = module.vpc.aws_vpc_id
  region             = var.aws_region
  availability_zones = local.availability_zones
  vpc_cidr           = var.vpc_cidr
  newbits            = var.newbits
  cluster_name       = var.cluster_name
}

module "eks" {
  source             = "../modules/eks"
  vpc_id             = module.vpc.aws_vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  cluster_name       = var.cluster_name
}


module "alb" {
  source             = "../modules/alb"
  vpc_id             = module.vpc.aws_vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  public_subnet_ids  = module.network.public_subnet_ids
  cluster_name       = var.cluster_name
  security_group     = module.eks.security_group
}

module "ec2" {
      source              = "../modules/ec2"
}
