output "vpc_id" {
  description = "ID of the VPC."
  value       = module.networking.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC."
  value       = module.networking.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "List of public subnet IDs."
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs."
  value       = module.networking.private_subnet_ids
}

output "nat_gateway_public_ips" {
  description = "Elastic IP addresses of NAT gateways."
  value       = module.networking.nat_gateway_public_ips
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

output "rds_security_group_id" {
  description = "Security group ID for RDS."
  value       = module.networking.rds_security_group_id
}

output "elasticache_security_group_id" {
  description = "Security group ID for ElastiCache."
  value       = module.networking.elasticache_security_group_id
}

output "route53_zone_id" {
  description = "Route53 hosted zone ID."
  value       = module.networking.route53_zone_id
}

output "route53_zone_name_servers" {
  description = "NS records — update domain registrar to delegate to these."
  value       = module.networking.route53_zone_name_servers
}

output "acm_certificate_arn" {
  description = "ARN of the ACM certificate."
  value       = module.networking.acm_certificate_arn
}

output "availability_zones" {
  description = "AZs used by the module."
  value       = module.networking.availability_zones
}
