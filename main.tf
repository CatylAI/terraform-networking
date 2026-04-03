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

  tags = merge(local.merged_tags, {
    Name                        = "${local.name_prefix}-public-${local.azs[count.index]}"
    "kubernetes.io/role/elb"    = "1"
    "kubernetes.io/cluster/any" = "shared"
  })
}

# -----------------------------------------------------------------------------
# Private Subnets
# -----------------------------------------------------------------------------

resource "aws_subnet" "private" {
  count = local.az_count

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = local.azs[count.index]

  tags = merge(local.merged_tags, {
    Name                                = "${local.name_prefix}-private-${local.azs[count.index]}"
    "kubernetes.io/role/internal-elb"   = "1"
    "kubernetes.io/cluster/any"         = "shared"
  })
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

  depends_on = [aws_internet_gateway.main]
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
