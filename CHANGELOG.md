# Changelog

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/), and this project adheres to [Semantic Versioning](https://semver.org/).

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
