# terraform-networking

Reusable Terraform module for CatylAI AWS networking infrastructure. Provisions the VPC, subnets, routing, security groups, Route53 hosted zone, and ACM certificate that all downstream modules depend on.

## Usage

```hcl
module "networking" {
  source = "git::https://github.com/CatylAI/terraform-networking.git?ref=v0.1.0"

  environment = "production"
  vpc_cidr    = "10.0.0.0/16"

  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]

  enable_ha_nat = true

  domain_name = "catylai.com"
}
```

### Composition with EKS

```hcl
module "networking" {
  source = "git::https://github.com/CatylAI/terraform-networking.git?ref=v0.1.0"

  environment = var.environment
  vpc_cidr    = "10.0.0.0/16"
  domain_name = "catylai.com"
}

module "eks" {
  source = "git::https://github.com/CatylAI/terraform-eks-cluster.git?ref=v1.0.0"

  environment                = var.environment
  vpc_id                     = module.networking.vpc_id
  private_subnet_ids         = module.networking.private_subnet_ids
  public_subnet_ids          = module.networking.public_subnet_ids
  cluster_security_group_id  = module.networking.eks_cluster_security_group_id
  node_security_group_id     = module.networking.eks_nodes_security_group_id
  certificate_arn            = module.networking.acm_certificate_arn
}
```

## Feature Toggles

| Toggle | Default | Description |
|---|---|---|
| `enable_nat_gateway` | `true` | Create NAT gateway(s) for private subnet internet access |
| `enable_ha_nat` | `false` | One NAT gateway per AZ (set `true` for production) |
| `enable_flow_logs` | `true` | VPC flow logs to CloudWatch |
| `enable_route53` | `true` | Create a Route53 public hosted zone |
| `enable_acm` | `true` | Create ACM wildcard certificate with DNS validation |

**Interaction note:** When `enable_acm = true`, either `enable_route53` must be `true` or `route53_zone_id` must be set (for DNS validation records).

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| `environment` | Deployment environment (dev, staging, production) | `string` | — | yes |
| `vpc_cidr` | CIDR block for the VPC | `string` | `"10.0.0.0/16"` | no |
| `public_subnet_cidrs` | CIDR blocks for public subnets (min 2) | `list(string)` | `["10.0.1.0/24", "10.0.2.0/24"]` | no |
| `private_subnet_cidrs` | CIDR blocks for private subnets (min 2) | `list(string)` | `["10.0.10.0/24", "10.0.11.0/24"]` | no |
| `enable_nat_gateway` | Create NAT gateway(s) | `bool` | `true` | no |
| `enable_ha_nat` | One NAT gateway per AZ | `bool` | `false` | no |
| `enable_flow_logs` | Enable VPC flow logs | `bool` | `true` | no |
| `flow_log_retention_days` | CloudWatch log retention (7/14/30/60/90/180/365) | `number` | `30` | no |
| `enable_route53` | Create Route53 hosted zone | `bool` | `true` | no |
| `domain_name` | Domain for Route53 zone and ACM cert | `string` | `""` | no |
| `route53_zone_id` | Existing Route53 zone ID (skip zone creation) | `string` | `""` | no |
| `enable_acm` | Create ACM certificate | `bool` | `true` | no |
| `certificate_sans` | Additional SANs beyond the default wildcard | `list(string)` | `[]` | no |
| `cluster_name` | EKS cluster name for subnet discovery tags (empty = placeholder `any`) | `string` | `""` | no |
| `tags` | Additional tags to merge with common tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|---|---|
| `vpc_id` | ID of the VPC |
| `vpc_cidr_block` | CIDR block of the VPC |
| `public_subnet_ids` | List of public subnet IDs |
| `private_subnet_ids` | List of private subnet IDs |
| `public_subnet_cidrs` | List of public subnet CIDR blocks |
| `private_subnet_cidrs` | List of private subnet CIDR blocks |
| `internet_gateway_id` | ID of the internet gateway |
| `nat_gateway_ids` | List of NAT gateway IDs |
| `nat_gateway_public_ips` | Elastic IP addresses of NAT gateways |
| `public_route_table_id` | ID of the public route table |
| `private_route_table_ids` | List of private route table IDs |
| `alb_security_group_id` | Security group ID for ALB |
| `eks_cluster_security_group_id` | Security group ID for EKS cluster |
| `eks_nodes_security_group_id` | Security group ID for EKS nodes |
| `rds_security_group_id` | Security group ID for RDS |
| `elasticache_security_group_id` | Security group ID for ElastiCache |
| `route53_zone_id` | Route53 hosted zone ID |
| `route53_zone_name_servers` | Name servers for the hosted zone |
| `acm_certificate_arn` | ARN of the ACM certificate |
| `acm_certificate_domain_name` | Domain name of the ACM certificate |
| `availability_zones` | List of AZs used |

## Security Groups

The module creates five security groups with least-privilege rules:

| Security Group | Ingress | Egress |
|---|---|---|
| **ALB** | 80, 443 from 0.0.0.0/0 | All |
| **EKS Cluster** | 443 from EKS nodes | 443, 10250 to EKS nodes |
| **EKS Nodes** | 10250, 443 from cluster; all from self; 1024-65535 from ALB | All |
| **RDS** | 5432 from EKS nodes | — |
| **ElastiCache** | 6379 from EKS nodes | — |

## Route53 NS Delegation

When creating a new hosted zone, the module outputs `route53_zone_name_servers`. You must update your domain registrar to delegate to these name servers for DNS to resolve.

## Examples

- [`examples/basic/`](examples/basic/) — Minimal VPC with subnets, routing, and security groups
- [`examples/complete/`](examples/complete/) — Full setup with HA NAT, flow logs, Route53, and ACM

## Requirements

| Name | Version |
|---|---|
| Terraform | `~> 1.14.0` |
| AWS provider | `~> 5.40` |
