output "vpc_id" {
  description = "ID of the VPC."
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs."
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs."
  value       = module.networking.private_subnet_ids
}

output "alb_security_group_id" {
  description = "Security group ID for ALB."
  value       = module.networking.alb_security_group_id
}

output "eks_cluster_security_group_id" {
  description = "Security group ID for EKS cluster."
  value       = module.networking.eks_cluster_security_group_id
}

output "eks_nodes_security_group_id" {
  description = "Security group ID for EKS nodes."
  value       = module.networking.eks_nodes_security_group_id
}
