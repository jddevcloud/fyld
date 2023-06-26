# New regional certificate

provider "aws" {}
provider "aws" {
  alias = "us-east-1"
}

resource "aws_acm_certificate" "env-cert" {
  domain_name               = var.primary_domain_name
  subject_alternative_names = concat(["*.${var.primary_domain_name}"], [for k in var.subdomains : k if k!=var.primary_domain_name])
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "env-cert-validation-record" {
  for_each = {
    for dvo in aws_acm_certificate.env-cert.domain_validation_options : dvo.domain_name => {
      name     = dvo.resource_record_name
      record   = dvo.resource_record_value
      type     = dvo.resource_record_type
      zone_id  = aws_route53_zone.hostedzone[
        element(
          split("*.", dvo.domain_name),
          length(split("*.", dvo.domain_name))-1
        )
      ].zone_id
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}

resource "aws_acm_certificate_validation" "env-cert-validation" {
  certificate_arn         = aws_acm_certificate.env-cert.arn
  validation_record_fqdns = [for record in aws_route53_record.env-cert-validation-record : record.fqdn]
}


# New global certificate

resource "aws_acm_certificate" "env-cert-cf" {
  domain_name               = var.primary_domain_name
  subject_alternative_names = concat(["*.${var.primary_domain_name}"], [for k in var.subdomains : k if k!=var.primary_domain_name])
  validation_method = "DNS"
  provider = aws.us-east-1

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_route53_record" "env-cert-cf-validation-record" {
  for_each = {
    for dvo in aws_acm_certificate.env-cert-cf.domain_validation_options : dvo.domain_name => {
      name     = dvo.resource_record_name
      record   = dvo.resource_record_value
      type     = dvo.resource_record_type
      zone_id  = aws_route53_zone.hostedzone[
        element(
          split("*.", dvo.domain_name),
          length(split("*.", dvo.domain_name))-1
        )
      ].zone_id
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}

resource "aws_acm_certificate_validation" "env-cert-cf-validation" {
  validation_record_fqdns = [for record in aws_route53_record.env-cert-cf-validation-record : record.fqdn]
  certificate_arn         = aws_acm_certificate.env-cert-cf.arn
  provider                = aws.us-east-1
}





