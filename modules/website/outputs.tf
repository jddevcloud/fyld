output "domain_name" {
  value = aws_cloudfront_distribution.distribution.domain_name
}

output "hosted_zone_id" {
  value = aws_cloudfront_distribution.distribution.hosted_zone_id
}

output "id" {
  value = aws_cloudfront_distribution.distribution.id
}

output "arn" {
  value = aws_cloudfront_distribution.distribution.arn
}
