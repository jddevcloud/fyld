resource "aws_acm_certificate" "cert" {
  domain_name               = "*.sitestream.app"
  subject_alternative_names = ["*.${var.environment}.sitestream.app"]
  validation_method         = "EMAIL"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn = aws_acm_certificate.cert.arn
}

resource "aws_acm_certificate" "env-cert" {
  domain_name       = "*.${var.environment}.sitestream.app"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.env-cert.domain_validation_options : dvo.domain_name => {
      name     = dvo.resource_record_name
      record   = dvo.resource_record_value
      type     = dvo.resource_record_type
      zone_id  = aws_route53_zone.domain.zone_id
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}
