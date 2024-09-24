provider "aws" {
    region = var.region
}

module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    cidr = var.vpc_cidr
    name = var.vpc_name
    public_subnets = var.public_subnets
    private_subnets = var.private_subnets
    azs = var.azs
    enable_nat_gateway = true
    enable_vpn_gateway = true
}

module "ecr" {
    source = "terraform-aws-modules/ecr/aws"
    repository_name   = var.ecr_name
    repository_type = var.ecr_type
}

module "ec2" {
    source  = "terraform-aws-modules/ec2-instance/aws"
    name = var.ec2_name
    subnet_id = module.vpc.public_subnets[0]
    instance_type = var.instance_type

    depends_on = [
        module.vpc
    ]
}

module "eks" {
    source  = "terraform-aws-modules/eks/aws"
    version = "~> 20.0"

    cluster_name = var.cluster_name
    cluster_version = var.k8s_version
    cluster_endpoint_public_access  = true

    vpc_id = module.vpc.vpc_id
    subnet_ids = module.vpc.private_subnets

    eks_managed_node_group_defaults = {
        instance_types = ["t2.micro"]
    }

    depends_on = [
        module.vpc
    ]
}