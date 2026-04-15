# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "environment" {
  description = "Deployment environment."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be one of: dev, staging, production."
  }
}

# -----------------------------------------------------------------------------
# VPC
# -----------------------------------------------------------------------------

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid CIDR block."
  }
}

# -----------------------------------------------------------------------------
# Subnets
# -----------------------------------------------------------------------------

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets. Must provide at least 2 for multi-AZ."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]

  validation {
    condition     = length(var.public_subnet_cidrs) >= 2
    error_message = "At least 2 public subnet CIDRs are required for multi-AZ deployment."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets. Must provide at least 2 for multi-AZ."
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]

  validation {
    condition     = length(var.private_subnet_cidrs) >= 2
    error_message = "At least 2 private subnet CIDRs are required for multi-AZ deployment."
  }
}

# -----------------------------------------------------------------------------
# NAT Gateway
# -----------------------------------------------------------------------------

variable "enable_nat_gateway" {
  description = "Whether to create NAT gateway(s) for private subnet internet access."
  type        = bool
  default     = true
}

variable "enable_ha_nat" {
  description = "Create one NAT gateway per AZ for high availability. When false, a single NAT gateway is shared."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# VPC Flow Logs
# -----------------------------------------------------------------------------

variable "enable_flow_logs" {
  description = "Enable VPC flow logs to CloudWatch Logs."
  type        = bool
  default     = true
}

variable "flow_log_retention_days" {
  description = "Number of days to retain VPC flow logs in CloudWatch."
  type        = number
  default     = 30

  validation {
    condition     = contains([7, 14, 30, 60, 90, 180, 365], var.flow_log_retention_days)
    error_message = "Retention must be one of: 7, 14, 30, 60, 90, 180, 365."
  }
}

# -----------------------------------------------------------------------------
# Route53
# -----------------------------------------------------------------------------

variable "enable_route53" {
  description = "Create a Route53 public hosted zone for the domain."
  type        = bool
  default     = true
}

variable "domain_name" {
  description = "Domain name for Route53 hosted zone and ACM certificate (e.g., catylai.com)."
  type        = string
  default     = ""

  validation {
    condition     = var.domain_name == "" || can(regex("^[a-zA-Z0-9][a-zA-Z0-9.-]+[a-zA-Z0-9]$", var.domain_name))
    error_message = "Domain name must be a valid DNS name (alphanumeric, hyphens, dots, no spaces)."
  }
}

variable "route53_zone_id" {
  description = "Existing Route53 hosted zone ID. When set with enable_route53=false, the module uses this zone instead of creating one."
  type        = string
  default     = ""
}

# -----------------------------------------------------------------------------
# ACM
# -----------------------------------------------------------------------------

variable "enable_acm" {
  description = "Create an ACM certificate with DNS validation via Route53. Requires domain_name to be set."
  type        = bool
  default     = true
}

variable "certificate_sans" {
  description = "Additional Subject Alternative Names for the ACM certificate beyond the default wildcard."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for san in var.certificate_sans :
      can(regex("^(\\*\\.)?([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z]{2,}$", san))
    ])
    error_message = "certificate_sans must be valid DNS names. Wildcards (*) are allowed only at the leftmost label (e.g., *.example.com)."
  }
}

variable "dns_validation_ttl" {
  description = "TTL (seconds) for Route53 DNS-validation records used by ACM. Lower values speed up issuance/renewal; higher values reduce query load."
  type        = number
  default     = 300

  validation {
    condition     = var.dns_validation_ttl >= 60 && var.dns_validation_ttl <= 3600
    error_message = "dns_validation_ttl must be between 60 and 3600 seconds."
  }
}

variable "enable_flow_logs_s3_archival" {
  description = "Enable S3 archival for VPC flow logs with Glacier lifecycle transition. Requires enable_flow_logs = true."
  type        = bool
  default     = false
}

variable "flow_log_kms_key_id" {
  description = "KMS key ARN for encrypting VPC flow log data. If omitted, uses default AWS encryption."
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# NACLs
# -----------------------------------------------------------------------------

variable "enable_nacls" {
  description = "Create subnet-level Network ACLs for public and private subnets."
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Kubernetes
# -----------------------------------------------------------------------------

variable "cluster_name" {
  description = "EKS cluster name for subnet discovery tags. When empty, K8s tags are omitted from subnets."
  type        = string
  default     = ""
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Naming
# -----------------------------------------------------------------------------

variable "project_name" {
  description = "Project name prefix for all resources (e.g., catylai, myproject)."
  type        = string
  default     = "catylai"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.project_name))
    error_message = "project_name must start and end with lowercase alphanumeric, and contain only lowercase letters, digits, and hyphens."
  }
}

# -----------------------------------------------------------------------------
# VPC Endpoints (optional)
# -----------------------------------------------------------------------------

variable "enable_vpc_endpoints" {
  description = "Create VPC endpoints for ECR (API+DKR), S3 (Gateway), and STS (Interface). Recommended for private subnets without NAT egress."
  type        = bool
  default     = false
}
