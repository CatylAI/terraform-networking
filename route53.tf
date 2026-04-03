# -----------------------------------------------------------------------------
# Route53 Public Hosted Zone
# -----------------------------------------------------------------------------

resource "aws_route53_zone" "main" {
  count = local.create_route53_zone ? 1 : 0

  name    = var.domain_name
  comment = "Public hosted zone for ${local.name_prefix}"

  tags = merge(local.merged_tags, {
    Name = "${local.name_prefix}-zone"
  })
}
