# -----------------------------------------------------------------------------
# ACM Certificate
# -----------------------------------------------------------------------------

resource "aws_acm_certificate" "main" {
  count = var.enable_acm ? 1 : 0

  domain_name               = var.domain_name
  subject_alternative_names = concat(["*.${var.domain_name}"], var.certificate_sans)
  validation_method         = "DNS"

  tags = merge(local.merged_tags, {
    Name = "${local.name_prefix}-cert"
  })

  lifecycle {
    create_before_destroy = true

    precondition {
      condition     = var.domain_name != ""
      error_message = "domain_name is required when enable_acm is true."
    }

    precondition {
      condition     = var.enable_route53 || var.route53_zone_id != ""
      error_message = "Either enable_route53 must be true or route53_zone_id must be set for ACM DNS validation."
    }
  }
}

# -----------------------------------------------------------------------------
# DNS Validation Records
# -----------------------------------------------------------------------------

resource "aws_route53_record" "acm_validation" {
  for_each = var.enable_acm ? {
    for dvo in aws_acm_certificate.main[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = var.dns_validation_ttl
  type            = each.value.type
  zone_id         = local.zone_id
}

# -----------------------------------------------------------------------------
# Certificate Validation Waiter
# -----------------------------------------------------------------------------

resource "aws_acm_certificate_validation" "main" {
  count = var.enable_acm ? 1 : 0

  certificate_arn         = aws_acm_certificate.main[0].arn
  validation_record_fqdns = [for record in aws_route53_record.acm_validation : record.fqdn]
}
