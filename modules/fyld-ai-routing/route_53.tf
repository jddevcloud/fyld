resource "aws_route53_zone" "hostedzone" {
  for_each = toset(concat([var.primary_domain_name], var.subdomains))
  name     = each.key
}

resource "aws_route53_record" "a-open" {
  for_each = aws_route53_zone.hostedzone
  zone_id  = each.value.zone_id
  name     = "open"
  type     = "A"
  ttl      = "300"
  records = var.open_firebase_ips
}
