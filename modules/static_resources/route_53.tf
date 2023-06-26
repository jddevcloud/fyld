resource "aws_route53_record" "static" {
  zone_id = var.domain_zone_id
  name    = var.primary_root_domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.distribution.domain_name
    zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
