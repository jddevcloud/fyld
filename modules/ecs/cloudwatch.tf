data "template_file" "metric_dashboard" {
  template = file("${path.module}/ecs-metric-dashboard.json")

  vars = {
    region         = var.region
    alb_arn_suffix = aws_lb.main.arn_suffix
    cluster_name   = aws_ecs_cluster.main.name
    service_name   = aws_ecs_service.main.name
  }
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-${var.env}-ecs-webserver"
  dashboard_body = data.template_file.metric_dashboard.rendered
}

resource "aws_sns_topic" "pager_duty_ecs" {
  name = "pager-duty-ecs-alarm-notification"
}

resource "aws_sns_topic_subscription" "pager_duty_ecs_https" {
  protocol               = "https"
  endpoint               = "https://events.eu.pagerduty.com/integration/423343b0d8684e0ac11b4bfc484f677e/enqueue"
  endpoint_auto_confirms = true
  topic_arn              = aws_sns_topic.pager_duty_ecs.arn
}

resource "aws_cloudwatch_metric_alarm" "pager_duty_ecs_response_avg_alarm" {
  alarm_name          = "ecs-${var.env}-response-avg"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "15"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  alarm_description   = "Average API response time >= 5s"
  threshold           = "5"
  alarm_actions       = [aws_sns_topic.pager_duty_ecs.arn]
  dimensions = {
    LoadBalancer      = aws_lb.main.arn_suffix
  }
}