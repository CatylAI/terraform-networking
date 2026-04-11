# -----------------------------------------------------------------------------
# VPC
# -----------------------------------------------------------------------------

output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC."
  value       = aws_vpc.main.cidr_block
}

# -----------------------------------------------------------------------------
# Subnets
# -----------------------------------------------------------------------------

output "public_subnet_ids" {
  description = "List of public subnet IDs."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs."
  value       = aws_subnet.private[*].id
}

output "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks."
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks."
  value       = aws_subnet.private[*].cidr_block
}

# -----------------------------------------------------------------------------
# Gateways
# -----------------------------------------------------------------------------

output "internet_gateway_id" {
  description = "ID of the internet gateway."
  value       = aws_internet_gateway.main.id
}

output "nat_gateway_ids" {
  description = "List of NAT gateway IDs."
  value       = aws_nat_gateway.main[*].id
}

output "nat_gateway_public_ips" {
  description = "Elastic IP addresses of NAT gateways."
  value       = aws_eip.nat[*].public_ip
  sensitive   = true
}

# -----------------------------------------------------------------------------
# Route Tables
# -----------------------------------------------------------------------------

output "public_route_table_id" {
  description = "ID of the public route table."
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "List of private route table IDs."
  value       = aws_route_table.private[*].id
}

# -----------------------------------------------------------------------------
# Security Groups
# -----------------------------------------------------------------------------

output "alb_security_group_id" {
  description = "Security group ID for Application Load Balancer."
  value       = aws_security_group.alb.id
}

output "eks_cluster_security_group_id" {
  description = "Security group ID for EKS cluster control plane."
  value       = aws_security_group.eks_cluster.id
}

output "eks_nodes_security_group_id" {
  description = "Security group ID for EKS worker nodes."
  value       = aws_security_group.eks_nodes.id
}

output "rds_security_group_id" {
  description = "Security group ID for RDS instances."
  value       = aws_security_group.rds.id
}

output "elasticache_security_group_id" {
  description = "Security group ID for ElastiCache instances."
  value       = aws_security_group.elasticache.id
}

# -----------------------------------------------------------------------------
# Route53
# -----------------------------------------------------------------------------

output "route53_zone_id" {
  description = "Route53 hosted zone ID. Empty string if Route53 is disabled."
  value       = local.create_route53_zone ? aws_route53_zone.main[0].zone_id : var.route53_zone_id
}

output "route53_zone_name_servers" {
  description = "Name servers for the Route53 hosted zone. Update your domain registrar to use these."
  value       = local.create_route53_zone ? aws_route53_zone.main[0].name_servers : []
}

# -----------------------------------------------------------------------------
# ACM
# -----------------------------------------------------------------------------

output "acm_certificate_arn" {
  description = "ARN of the ACM certificate. Empty string if ACM is disabled."
  value       = var.enable_acm ? aws_acm_certificate.main[0].arn : ""
}

output "acm_certificate_domain_name" {
  description = "Domain name of the ACM certificate."
  value       = var.enable_acm ? aws_acm_certificate.main[0].domain_name : ""
}

# -----------------------------------------------------------------------------
# Metadata
# -----------------------------------------------------------------------------

output "availability_zones" {
  description = "List of availability zones used by the module."
  value       = local.azs
}
