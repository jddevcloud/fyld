resource "aws_lb" "main" {
  name               = "${var.project_name}-${var.env}"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnets
  security_groups    = [aws_security_group.lb.id, aws_security_group.http_lb.id]

  access_logs {
    bucket  = aws_s3_bucket.lb_logs.bucket
    enabled = true
  }
}

resource "aws_lb_target_group" "main" {
  name                 = "${var.project_name}-${var.env}-${random_id.target_group_sufix.hex}"
  port                 = var.container_port
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = var.vpc_id
  deregistration_delay = 30

  health_check {
    path                = "/healthcheck"
    matcher             = "200"
    interval            = "30"
    timeout             = "20"
    healthy_threshold   = 2
    unhealthy_threshold = 4
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.id
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.lb_certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Access denied"
      status_code  = "403"
    }
  }
}

resource "aws_lb_listener_rule" "only_allow_from_cloudfront" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100

  action {
    target_group_arn = aws_lb_target_group.main.id
    type             = "forward"
  }

  condition {
    http_header {
      http_header_name = "X-Cloudfront-Access"
      values           = [var.cloudfront_custom_header]
    }
  }
}

resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.main.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
