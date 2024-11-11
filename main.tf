provider "aws" {
  region = var.region
}
# FRONTEND ECR
resource "aws_ecr_repository" "devops_ecr_frontend" {
  name                 = "${var.ecr_name}-frontend"
  image_tag_mutability = var.image_tag_mutability ? "IMMUTABLE" : "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name  = "Devops Frontend Repository"
    Group = "Devops"
  }
}

resource "aws_ecr_lifecycle_policy" "frontend_lifecycle_policy" {
  repository = aws_ecr_repository.devops_ecr_frontend.name
  policy     = <<EOF
  {
    "rules": 
    [
      {
        "rulePriority": 1,
        "description": "Expire images older than 14 days",
        "selection": {
          "tagStatus": "untagged",
          "countType": "sinceImagePushed",
          "countUnit": "days",
          "countNumber": 14
        },
        "action": {
          "type": "expire"
        }
      }
    ]
  }
  EOF
  depends_on = [
    aws_ecr_repository.devops_ecr_frontend
  ]
}

resource "aws_ecr_repository_policy" "frontend_repository_policy" {
  repository = aws_ecr_repository.devops_ecr_frontend.name
  policy     = <<EOF
  {
    "Version": "2008-10-17",
    "Statement": 
    [
      {
        "Sid": "Frontend ECR repository policy",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:DescribeImageScanFindings"
        ]
      }
    ]
  }
  EOF
  depends_on = [
    aws_ecr_repository.devops_ecr_frontend
  ]
}

# BACKEND ECR
resource "aws_ecr_repository" "devops_ecr_backend" {
  name                 = "${var.ecr_name}-backend"
  image_tag_mutability = var.image_tag_mutability ? "IMMUTABLE" : "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name  = "Devops Backend Repository"
    Group = "Devops"
  }
}

resource "aws_ecr_lifecycle_policy" "backend_lifecycle_policy" {
  repository = aws_ecr_repository.devops_ecr_backend.name
  policy     = <<EOF
  {
    "rules": 
    [
      {
        "rulePriority": 1,
        "description": "Expire images older than 14 days",
        "selection": {
          "tagStatus": "untagged",
          "countType": "sinceImagePushed",
          "countUnit": "days",
          "countNumber": 14
        },
        "action": {
          "type": "expire"
        }
      }
    ]
  }
  EOF
  depends_on = [
    aws_ecr_repository.devops_ecr_backend
  ]
}

resource "aws_ecr_repository_policy" "backend_repository_policy" {
  repository = aws_ecr_repository.devops_ecr_backend.name
  policy     = <<EOF
  {
    "Version": "2008-10-17",
    "Statement": 
    [
      {
        "Sid": "Backend ECR repository policy",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:DescribeImageScanFindings"
        ]
      }
    ]
  }
  EOF
  depends_on = [
    aws_ecr_repository.devops_ecr_backend
  ]
}

# VPC
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
  ingress_rules       = ["ssh-tcp", "minio-tcp", "http-8080-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules        = ["ssh-tcp", "minio-tcp", "http-8080-tcp"]
}

# EC2
data "aws_ami" "base_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["devops-ec2-ami-1"]
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

# EKS
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name                    = var.cluster_name
  cluster_version                 = var.k8s_version
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = false

  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.private_subnets
  cluster_security_group_id = module.security_group.security_group_id
  eks_managed_node_group_defaults = {
    instance_types = ["t2.small"]
  }
  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t2.small"]

      min_size     = 1
      max_size     = 3
      desired_size = 1
    }
  }
  enable_cluster_creator_admin_permissions = true
  depends_on = [
    module.vpc
  ]
}
