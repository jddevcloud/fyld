resource "aws_acm_certificate" "cloudfront-cert" {
  domain_name               = "*.sitestream.app"
  subject_alternative_names = ["*.${var.environment}.sitestream.app"]
  validation_method         = "EMAIL"

  lifecycle {
    create_before_destroy = true
  }
}
