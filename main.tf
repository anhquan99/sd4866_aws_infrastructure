provider "aws" {
  region = var.region
}

resource "aws_ecr_repository" "devops_ecr" {
  name                 = var.ecr_name
  image_tag_mutability = "MUTABLE"
}

module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  cidr               = var.vpc_cidr
  name               = var.vpc_name
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  azs                = var.azs
  enable_nat_gateway = true
  enable_vpn_gateway = true
}
module "security_group" {
  source              = "terraform-aws-modules/security-group/aws"
  name                = var.sg_name
  vpc_id              = module.vpc.vpc_id
  ingress_rules       = ["ssh-tcp", "https-443-tcp", "https-8443-tcp", "http-80-tcp", "http-8080-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules        = ["ssh-tcp", "https-443-tcp", "https-8443-tcp", "http-80-tcp", "http-8080-tcp"]
}

data "aws_ami" "base_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "devops_ec2" {
  ami                         = data.aws_ami.base_ami.id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  subnet_id                   = module.vpc.public_subnets[0]
  security_groups             = [module.security_group.security_group_id]
  tags = {
    Name = var.ec2_name
  }
  depends_on = [
    module.vpc,
    module.security_group
  ]
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name                   = var.cluster_name
  cluster_version                = var.k8s_version
  cluster_endpoint_public_access = true

  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.private_subnets
  cluster_security_group_id = module.security_group.security_group_id
  eks_managed_node_group_defaults = {
    instance_types = ["t2.micro"]
  }
  enable_cluster_creator_admin_permissions = true
  depends_on = [
    module.vpc
  ]
}