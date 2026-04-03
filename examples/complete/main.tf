provider "aws" {
  region = var.region
}

module "networking" {
  source = "../../"

  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  # HA NAT: one per AZ for production resilience
  enable_nat_gateway = true
  enable_ha_nat      = true

  # Flow logs
  enable_flow_logs       = true
  flow_log_retention_days = 90

  # Route53
  enable_route53 = true
  domain_name    = var.domain_name

  # ACM wildcard certificate
  enable_acm     = true
  certificate_sans = ["api.${var.domain_name}"]

  tags = {
    CostCenter = "platform"
  }
}
