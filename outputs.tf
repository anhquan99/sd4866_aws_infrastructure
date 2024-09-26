output "vpc_id" {
  value       = try(module.vpc.vpc_id, "")
  description = "The ID of the VPC"
}

output "vpc_cidr_block" {
  value       = try(module.vpc.vpc_cidr_block, "")
  description = "The CIDR block of the VPC"
}

output "public_subnet_ids" {
  value       = try(module.vpc.public_subnets, "")
  description = "List of IDs of the public subnets"
}

output "private_subnet_ids" {
  value       = try(module.vpc.private_subnets, "")
  description = "List of IDs of the private subnets"
}

output "nat_gateway_id" {
  value       = try(module.vpc.nat_gateway_ids[0], "")
  description = "The ID of the NAT gateway"
}

output "vpn_gateway_id" {
  value       = try(module.vpc.vpn_gateway_id, "")
  description = "The ID of the VPN gateway"
}

output "devops_ec2_public_ip" {
  value       = try(aws_instance.devops_ec2.public_ip, "")
  description = "The public IP address of the devops_ec2 instance"
}

output "devops_ec2_private_ip" {
  value       = try(aws_instance.devops_ec2.private_ip, "")
  description = "The private IP address of the devops_ec2 instance"
}

output "devops_ec2_id" {
  value       = try(aws_instance.devops_ec2.id, "")
  description = "The ID of the devops_ec2 instance"
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = try(module.eks.arn, "")
}

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = try(module.eks.endpoint, "")
}

output "cluster_name" {
  description = "The name of the EKS cluster. Will block on cluster creation until the cluster is really ready"
  value       = try(module.eks.name, "")
}

output "cluster_id" {
  description = "The id of the EKS cluster. Will block on cluster creation until the cluster is really ready"
  value       = try(module.eks.id, "")
}

output "cluster_version" {
  description = "The Kubernetes version for the cluster"
  value       = try(module.eks.version, "")
}

output "cluster_platform_version" {
  description = "Platform version for the cluster"
  value       = try(module.eks.platform_version, "")
}

output "cluster_status" {
  description = "Status of the EKS cluster. One of `CREATING`, `ACTIVE`, `DELETING`, `FAILED`"
  value       = try(module.eks.status, "")
}
