resource "aws_route53_zone" "domain" {
  name = "${var.environment}.sitestream.app"
}

resource "aws_route53_record" "a-open" {
  zone_id = aws_route53_zone.domain.zone_id
  name    = "open"
  type    = "A"
  ttl     = "300"
  records = var.open_firebase_ips
}
