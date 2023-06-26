locals {
  metrics = [
    "maestro-${var.env}-accuweather",
    "maestro-${var.env}-save-transcription",
    "maestro-${var.env}-predict",
    "maestro-${var.env}-publish",
    "maestro-${var.env}-join-job",
    "maestro-${var.env}-new-message",
    "maestro-${var.env}-transcribe",
    "maestro-${var.env}-leave-job",
    "maestro-${var.env}-update-models",
    "maestro-${var.env}-authorizer",
    "maestro-${var.env}-custom-resource-existing-s3",
    "maestro-${var.env}-custom-resource-existing-cup",
    "maestro-${var.env}-connection",
    "maestro-${var.env}-orchestrate",
    "maestro-${var.env}-pre-signup",
    "maestro-${var.env}-post-authentication",
    "maestro-${var.env}-predictv2",
    "maestro-${var.env}-hazard-title-predictor",
    "maestro-${var.env}-trainv2",
    "maestro-${var.env}-update-modelsv2",
    "maestro-${var.env}-initialize-models",
    "maestro-${var.env}-thumbnailerv2",
    "maestro-${var.env}-video-classifier",
    "maestro-${var.env}-postgres-backupv2",
    "maestro-${var.env}-clamav-scan",
    "maestro-${var.env}-clamav-download-defs",
    "maestro-${var.env}-define-auth-challenge",
    "maestro-${var.env}-create-auth-challenge",
    "maestro-${var.env}-verify-auth-challenge",
  ]

  p99_error_metric_format    = "[\"AWS/Lambda\", \"Errors\", \"FunctionName\", \"%v\", { \"stat\" : \"p99\" }]"
  p95_error_metric_format    = "[\"AWS/Lambda\", \"Errors\", \"FunctionName\", \"%v\", { \"stat\" : \"p95\" }]"
  p99_duration_metric_format = "[\"AWS/Lambda\", \"Duration\", \"FunctionName\", \"%v\", { \"stat\" : \"p99\" }]"
  p95_duration_metric_format = "[\"AWS/Lambda\", \"Duration\", \"FunctionName\", \"%v\", { \"stat\" : \"p95\" }]"
  invocations_metric_format  = "[\"AWS/Lambda\", \"Invocations\", \"FunctionName\", \"%v\"]"
  throttles_metric_format    = "[\"AWS/Lambda\", \"Throttles\", \"FunctionName\", \"%v\"]"
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-${var.env}-maestro-lambdas"
  dashboard_body = <<EOF
{
  "widgets": [
    {
      "type": "metric",
      "width": 12,
      "height": 6,
      "x": 0,
      "y": 0,
      "properties": {
        "region": "${var.region}",
        "title": "Lambda Errors By Function (p99)",
        "metrics": [
          ${join(",", formatlist(local.p99_error_metric_format, local.metrics))}
        ],
        "view": "timeSeries",
        "stacked": false,
        "period": 300
      }
    },
    {
      "type": "metric",
      "width": 12,
      "height": 6,
      "x": 12,
      "y": 0,
      "properties": {
        "region": "${var.region}",
        "title": "Lambda Errors By Function (p95)",
        "metrics": [
          ${join(",", formatlist(local.p95_error_metric_format, local.metrics))}
        ],
        "view": "timeSeries",
        "stacked": false,
        "period": 300
      }
    },
    {
      "type": "metric",
      "width": 12,
      "height": 6,
      "x": 0,
      "y": 6,
      "properties": {
        "region": "${var.region}",
        "title": "Lambda Duration By Function (p99)",
        "metrics": [
          ${join(",", formatlist(local.p99_duration_metric_format, local.metrics))}
        ],
        "view": "timeSeries",
        "stacked": false,
        "period": 300
      }
    },
    {
      "type": "metric",
      "width": 12,
      "height": 6,
      "x": 12,
      "y": 6,
      "properties": {
        "region": "${var.region}",
        "title": "Lambda Duration By Function (p95)",
        "metrics": [
          ${join(",", formatlist(local.p95_duration_metric_format, local.metrics))}
        ],
        "view": "timeSeries",
        "stacked": false,
        "period": 300
      }
    },
    {
      "type": "metric",
      "width": 12,
      "height": 6,
      "x": 0,
      "y": 12,
      "properties": {
        "region": "${var.region}",
        "title": "Lambda Invocations By Function",
        "metrics": [
          ${join(",", formatlist(local.invocations_metric_format, local.metrics))}
        ],
        "view": "timeSeries",
        "stacked": false,
        "period": 300,
        "stat": "Sum"
      }
    },
    {
      "type": "metric",
      "width": 12,
      "height": 6,
      "x": 12,
      "y": 12,
      "properties": {
        "region": "${var.region}",
        "title": "Lambda Throttles By Function",
        "metrics": [
          ${join(",", formatlist(local.throttles_metric_format, local.metrics))}
        ],
        "view": "timeSeries",
        "stacked": false,
        "period": 300,
        "stat": "Sum"
      }
    }
  ]
}
EOF
}

resource "aws_sns_topic" "sns_error_alert_topic" {
  name = "lambda-alarm-notification"
}

resource "aws_sns_topic" "pager_duty_maestro" {
  name = "pager-duty-maestro-alarm-notification"
}

resource "aws_sns_topic_subscription" "pager_duty_maestro_https" {
  protocol               = "https"
  endpoint               = "https://events.eu.pagerduty.com/integration/423343b0d8684e0ac11b4bfc484f677e/enqueue"
  endpoint_auto_confirms = true
  topic_arn              = aws_sns_topic.pager_duty_maestro.arn
}

resource "aws_cloudwatch_metric_alarm" "maestro_alarms" {
  count               = length(local.metrics)
  alarm_name          = "${local.metrics[count.index]}-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "5"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Sum"
  alarm_description   = "Number of lambda errors >= 5"
  threshold           = "5"
  alarm_actions       = [aws_sns_topic.sns_error_alert_topic.arn]
  dimensions = {
    FunctionName      = local.metrics[count.index]
  }
}

resource "aws_cloudwatch_metric_alarm" "pager_duty_maestro_alarms" {
  count               = length(local.metrics)
  alarm_name          = "${local.metrics[count.index]}-pagerduty-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "5"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Sum"
  alarm_description   = "Number of lambda errors >= 5"
  threshold           = "5"
  alarm_actions       = [aws_sns_topic.pager_duty_maestro.arn]
  dimensions = {
    FunctionName      = local.metrics[count.index]
  }
}


# # TODO: Create custom alerts
# Namespace: AWS/ApplicationELB
# Metric name: HTTPCode_Target_4XX_Count
# LoadBalancer: app/sitestream-production/68ed4500e9da620f
# Statistic: Sum
# Period: 5 minutes
# Threshold type: Anomaly detection
# Define the alarm condition: Greater than the band
# Anomaly detection threshold: 6
# Datapoints to alarm: 2 out of 2
# Missing data treatment: Treat missing data as missing