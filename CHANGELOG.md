# Changelog

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/), and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- LOW polish deferred via #170: test scaffolding (`tests/basic.tftest.hcl`), `.tflint.hcl` with AWS ruleset, and `Makefile` with `fmt/validate/lint/test/plan/clean` targets.
- New `dns_validation_ttl` variable (default `300`, range 60–3600) controlling TTL of ACM DNS-validation records.
- `lifecycle { ignore_changes }` on `aws_subnet.public` / `aws_subnet.private` for `kubernetes.io/role/*` tags that EKS controllers manage out-of-band.

### Changed

- Removed redundant `depends_on = [aws_internet_gateway.main]` from `aws_eip.nat` (VPC-domain EIPs do not require an IGW; NAT gateway still depends on IGW).

## [0.2.0] - 2026-04-12

### Added

- Optional VPC endpoints for ECR (API + DKR), S3 (Gateway), and STS (Interface), gated by `var.enable_vpc_endpoints` (default `false`)
- VPC endpoints security group with HTTPS ingress from VPC CIDR only
- `var.project_name` (string, default `"catylai"`) — configurable resource name prefix
- Format validation on `var.certificate_sans` (DNS-label regex with optional leftmost `*` wildcard)
- Format validation on `var.project_name` (lowercase alphanumeric + hyphens)

### Changed

- Replaced hardcoded `"catylai"` name prefix with `var.project_name` in `locals.tf` (backward-compatible: default matches prior behavior)
- Scoped VPC flow logs IAM policy from `Resource = "*"` to the specific log group ARN + `:log-stream:*` form; dropped unnecessary `logs:CreateLogGroup` and `logs:DescribeLogGroups` actions

### Fixed

- Added explicit empty `filter {}` block to `aws_s3_bucket_lifecycle_configuration.flow_logs` — silences AWS provider warning and keeps the rule valid in provider v6.x (where the unfiltered form becomes an error)

## [0.1.0] - 2026-04-03

### Added

- VPC with configurable CIDR, DNS support, and DNS hostnames
- Public subnets (2+ AZs) with internet gateway routing
- Private subnets (2+ AZs) with NAT gateway routing
- Internet gateway with public route table
- Configurable NAT: single gateway (dev) or HA one-per-AZ (production)
- Private route tables with NAT gateway routes
- Security groups: ALB, EKS cluster, EKS nodes, RDS, ElastiCache
- VPC flow logs to CloudWatch (toggleable, configurable retention)
- Route53 public hosted zone (create new or use existing)
- ACM wildcard certificate with DNS validation via Route53
- Kubernetes subnet tags for AWS Load Balancer Controller discovery
- Standard CatylAI resource naming (`catylai-<environment>-<resource>`)
- Mandatory tags: Project, Environment, ManagedBy, Team
- Complete examples: basic and complete configurations
