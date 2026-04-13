locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Team        = "platform"
  }

  merged_tags = merge(local.common_tags, var.tags)

  # Use the minimum of available AZs and requested subnet count
  az_count = min(
    length(var.public_subnet_cidrs),
    length(data.aws_availability_zones.available.names)
  )
  azs = slice(data.aws_availability_zones.available.names, 0, local.az_count)

  # NAT gateway count: one per AZ in HA mode, or one shared
  nat_gateway_count = var.enable_nat_gateway ? (var.enable_ha_nat ? local.az_count : 1) : 0

  # Private route table count: one per AZ in HA mode (each AZ routes through its own NAT),
  # or a single shared route table when using a single NAT gateway
  private_rt_count = var.enable_ha_nat ? local.az_count : 1

  # Route53 zone resolution
  create_route53_zone = var.enable_route53 && var.route53_zone_id == ""
  zone_id = (
    local.create_route53_zone
    ? aws_route53_zone.main[0].zone_id
    : var.route53_zone_id
  )
}
