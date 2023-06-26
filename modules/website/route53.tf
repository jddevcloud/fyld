resource "aws_route53_record" "website" {
  for_each = var.domain_zone_ids

  name    = var.primary_root_domain
  type    = "A"
  zone_id = each.value.zone_id

  alias {
    name                   = aws_cloudfront_distribution.distribution.domain_name
    zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
    evaluate_target_health = false
  }

}
