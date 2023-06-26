resource "aws_sns_topic" "pager_duty_database" {
  name = "pager-duty-database-alarm-notification"
}

resource "aws_sns_topic_subscription" "pager_duty_database_https" {
  protocol               = "https"
  endpoint               = "https://events.eu.pagerduty.com/integration/423343b0d8684e0ac11b4bfc484f677e/enqueue"
  endpoint_auto_confirms = true
  topic_arn              = aws_sns_topic.pager_duty_database.arn
}

resource "aws_cloudwatch_metric_alarm" "pager_duty_database_response_avg_alarm" {
  alarm_name          = "rds-${var.env}-free-space"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "15"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  alarm_description   = "Free database storage space"
  threshold           = "5000000000"
  alarm_actions       = [aws_sns_topic.pager_duty_database.arn]
  dimensions = {
    DBInstanceIdentifier      = aws_db_instance.default.identifier
  }
}