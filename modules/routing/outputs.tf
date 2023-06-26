output "name_servers" {
  value = aws_route53_zone.domain.name_servers
}

output "domain_zone_id" {
  value = aws_route53_zone.domain.zone_id
}

output "regional_certificate_arn" {
  value = aws_acm_certificate.env-cert.arn
}

output "main_certificate_arn" {
  value = aws_acm_certificate.cert.arn
}
