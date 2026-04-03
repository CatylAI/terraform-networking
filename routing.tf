# -----------------------------------------------------------------------------
# Public Route Table
# -----------------------------------------------------------------------------

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.merged_tags, {
    Name = "${local.name_prefix}-public-rt"
  })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count = local.az_count

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# -----------------------------------------------------------------------------
# Private Route Tables
# -----------------------------------------------------------------------------

resource "aws_route_table" "private" {
  count = var.enable_ha_nat ? local.az_count : 1

  vpc_id = aws_vpc.main.id

  tags = merge(local.merged_tags, {
    Name = "${local.name_prefix}-private-rt-${count.index}"
  })
}

resource "aws_route" "private_nat" {
  count = local.nat_gateway_count > 0 ? (var.enable_ha_nat ? local.az_count : 1) : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[var.enable_ha_nat ? count.index : 0].id
}

resource "aws_route_table_association" "private" {
  count = local.az_count

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[var.enable_ha_nat ? count.index : 0].id
}
