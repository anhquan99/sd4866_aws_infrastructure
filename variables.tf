variable "region" {
  type        = string
  description = "aws region"
  default     = "ap-southeast-1"
}

variable "vpc_name" {
  type        = string
  description = "name of the vpc to be created"
  default     = "eks-vpc"
}

variable "vpc_cidr" {
  type        = string
  description = "vpc cidr block to be used"
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  type        = list(string)
  description = "public subnets to be created"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnets" {
  type        = list(string)
  description = "private subnets to be created"
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "azs" {
  type        = list(string)
  description = "availability zones"
  default     = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
}

variable "ecr_name" {
  type        = string
  description = "name of the ecr to be created"
  default     = "devops-ecr"
}

variable "ecr_type" {
  type        = string
  description = "ecr type"
  default     = "public"
}

variable "ec2_name" {
  type        = string
  description = "name of the ec2 to be created"
  default     = "devops-ec2"
}

variable "instance_type" {
  type        = string
  description = "ec2 instance type"
  default     = "t2.micro"
}

variable "cluster_name" {
  type        = string
  description = "eks cluster name"
  default     = "devops-eks"
}

variable "k8s_version" {
  type        = string
  description = "k8s version"
  default     = "1.30"
}