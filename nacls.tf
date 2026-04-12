# -----------------------------------------------------------------------------
# Public Subnet NACLs
# -----------------------------------------------------------------------------

resource "aws_network_acl" "public" {
  count = var.enable_nacls ? 1 : 0

  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.public[*].id

  tags = merge(local.merged_tags, {
    Name = "${local.name_prefix}-public-nacl"
  })
}

resource "aws_network_acl_rule" "public_ingress_http" {
  count = var.enable_nacls ? 1 : 0

  network_acl_id = aws_network_acl.public[0].id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "public_ingress_https" {
  count = var.enable_nacls ? 1 : 0

  network_acl_id = aws_network_acl.public[0].id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "public_ingress_ephemeral" {
  count = var.enable_nacls ? 1 : 0

  network_acl_id = aws_network_acl.public[0].id
  rule_number    = 120
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "public_ingress_vpc" {
  count = var.enable_nacls ? 1 : 0

  network_acl_id = aws_network_acl.public[0].id
  rule_number    = 130
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl_rule" "public_egress_all" {
  count = var.enable_nacls ? 1 : 0

  network_acl_id = aws_network_acl.public[0].id
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}

# -----------------------------------------------------------------------------
# Private Subnet NACLs
# -----------------------------------------------------------------------------

resource "aws_network_acl" "private" {
  count = var.enable_nacls ? 1 : 0

  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.private[*].id

  tags = merge(local.merged_tags, {
    Name = "${local.name_prefix}-private-nacl"
  })
}

resource "aws_network_acl_rule" "private_ingress_vpc" {
  count = var.enable_nacls ? 1 : 0

  network_acl_id = aws_network_acl.private[0].id
  rule_number    = 100
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl_rule" "private_ingress_ephemeral" {
  count = var.enable_nacls ? 1 : 0

  network_acl_id = aws_network_acl.private[0].id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "private_egress_all" {
  count = var.enable_nacls ? 1 : 0

  network_acl_id = aws_network_acl.private[0].id
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}
