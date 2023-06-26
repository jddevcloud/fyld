output "primary_domain_zone_id" {
  value = aws_route53_zone.hostedzone[var.primary_domain_name].zone_id
}

output "domain_zones" {
  value = aws_route53_zone.hostedzone
}

output "regional_certificate_arn" {
  value = aws_acm_certificate.env-cert.arn
}

output "cloudfront_certificate_arn" {
  value = aws_acm_certificate.env-cert-cf.arn
}
