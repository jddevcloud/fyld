resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "The default cloudfront access identity"
}

resource "aws_cloudfront_distribution" "distribution" {
  web_acl_id = var.waf_enabled ? aws_waf_web_acl.waf_acl[0].id : ""

  origin {
    domain_name = aws_s3_bucket.data.bucket_domain_name
    origin_id   = "${var.project_name}-${var.env}-maestro"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.project_name}-${var.env}-maestro"
  default_root_object = "index.html"

  aliases     = var.cloudfront_domain_names
  price_class = "PriceClass_100"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "${var.project_name}-${var.env}-maestro"

    forwarded_values {
      query_string = true
      headers = [
        "Access-Control-Request-Headers",
        "Access-Control-Request-Method",
        "Origin"
      ]

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    default_ttl            = 7200
    min_ttl                = 0
    max_ttl                = 31536000
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
