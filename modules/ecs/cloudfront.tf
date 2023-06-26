resource "aws_cloudfront_distribution" "distribution" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "${var.project_name}-${var.env}-api-ecs"

  aliases     = var.domain_names
  price_class = "PriceClass_100"

  web_acl_id = var.waf_enabled ? aws_waf_web_acl.waf_acl[0].id : ""

  origin {
    domain_name = aws_lb.main.dns_name
    origin_id   = "${var.project_name}-${var.env}-load-balancer"
    custom_header {
      name = "X-Cloudfront-Access"
      value = var.cloudfront_custom_header
    }
    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "DELETE", "PUT", "POST", "PATCH"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "${var.project_name}-${var.env}-load-balancer"

    forwarded_values {
      query_string = true
      headers      = ["*"]

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3
    max_ttl                = 30
    compress               = true
  }

  viewer_certificate {
    acm_certificate_arn      = var.cf_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
