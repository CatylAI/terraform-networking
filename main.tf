# -----------------------------------------------------------------------------
# VPC
# -----------------------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.merged_tags, {
    Name = "${local.name_prefix}-vpc"
  })

  lifecycle {
    precondition {
      condition     = length(var.public_subnet_cidrs) == length(var.private_subnet_cidrs)
      error_message = "public_subnet_cidrs and private_subnet_cidrs must have the same length (one per AZ)."
    }

    precondition {
      condition     = !var.enable_acm || var.domain_name != ""
      error_message = "domain_name must not be empty when enable_acm is true."
    }
  }
}

# -----------------------------------------------------------------------------
# Internet Gateway
# -----------------------------------------------------------------------------

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.merged_tags, {
    Name = "${local.name_prefix}-igw"
  })
}

# -----------------------------------------------------------------------------
# Public Subnets
# -----------------------------------------------------------------------------

resource "aws_subnet" "public" {
  count = local.az_count

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.merged_tags,
    { Name = "${local.name_prefix}-public-${local.azs[count.index]}" },
    var.cluster_name != "" ? {
      "kubernetes.io/role/elb"                    = "1"
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    } : {}
  )

  # Ignore drift on kubernetes.io/cluster/* tags that EKS controllers (AWS Load Balancer
  # Controller, Cluster Autoscaler, Karpenter) may manage out-of-band. Terraform requires
  # literal keys in ignore_changes, so we ignore the full tags map on the k8s cluster
  # tag-key-prefix to keep noise out of plans.
  lifecycle {
    ignore_changes = [
      tags["kubernetes.io/role/elb"],
      tags["kubernetes.io/role/internal-elb"],
    ]
  }
}

# -----------------------------------------------------------------------------
# Private Subnets
# -----------------------------------------------------------------------------

resource "aws_subnet" "private" {
  count = local.az_count

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = local.azs[count.index]

  tags = merge(local.merged_tags,
    { Name = "${local.name_prefix}-private-${local.azs[count.index]}" },
    var.cluster_name != "" ? {
      "kubernetes.io/role/internal-elb"           = "1"
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    } : {}
  )

  # Ignore drift on kubernetes.io/* tags that EKS controllers (AWS Load Balancer
  # Controller, Cluster Autoscaler, Karpenter) may manage out-of-band.
  lifecycle {
    ignore_changes = [
      tags["kubernetes.io/role/elb"],
      tags["kubernetes.io/role/internal-elb"],
    ]
  }
}

# -----------------------------------------------------------------------------
# Elastic IPs for NAT Gateways
# -----------------------------------------------------------------------------

resource "aws_eip" "nat" {
  count = local.nat_gateway_count

  domain = "vpc"

  tags = merge(local.merged_tags, {
    Name = "${local.name_prefix}-nat-eip-${count.index}"
  })

  # Note: no explicit depends_on IGW — VPC-domain EIPs do not require an IGW.
  # The NAT gateway itself still requires the IGW (see aws_nat_gateway.main).
}

# -----------------------------------------------------------------------------
# NAT Gateways
# -----------------------------------------------------------------------------

resource "aws_nat_gateway" "main" {
  count = local.nat_gateway_count

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(local.merged_tags, {
    Name = "${local.name_prefix}-nat-${local.azs[count.index]}"
  })

  depends_on = [aws_internet_gateway.main]
}
