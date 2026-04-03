provider "aws" {
  region = var.region
}

module "networking" {
  source = "../../"

  environment = var.environment
  vpc_cidr    = "10.0.0.0/16"

  # Disable optional features for minimal setup
  enable_route53 = false
  enable_acm     = false
}
