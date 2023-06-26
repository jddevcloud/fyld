resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-${var.env}-all-lambdas"
  dashboard_body = <<EOF
{
  "widgets": [
    {
      "type": "metric",
      "width": 24,
      "height": 6,
      "x": 0,
      "y": 0,
      "properties": {
        "region": "${var.region}",
        "title": "Lambda Errors Across All",
        "metrics": [
          ["AWS/Lambda", "Errors", {"stat": "Maximum"}],
          ["AWS/Lambda", "Errors", {"stat": "Average"}],
          ["AWS/Lambda", "Errors", {"stat": "Minimum"}]
        ],
        "view": "timeSeries",
        "stacked": false,
        "period": 300
      }
    },
    {
      "type": "metric",
      "width": 24,
      "height": 6,
      "x": 0,
      "y": 12,
      "properties": {
        "region": "${var.region}",
        "title": "Lambda Duration Across All",
        "metrics": [
          ["AWS/Lambda", "Duration", {"stat": "Maximum"}],
          ["AWS/Lambda", "Duration", {"stat": "Average"}],
          ["AWS/Lambda", "Duration", {"stat": "Minimum"}]
        ],
        "view": "timeSeries",
        "stacked": false,
        "period": 300
      }
    },
    {
      "type": "metric",
      "width": 24,
      "height": 6,
      "x": 0,
      "y": 24,
      "properties": {
        "region": "${var.region}",
        "title": "Lambda Invocations Across All",
        "metrics": [
          ["AWS/Lambda", "Invocations", {"stat": "Sum"}]
        ],
        "view": "timeSeries",
        "stacked": false,
        "period": 300
      }
    },
    {
      "type": "metric",
      "width": 24,
      "height": 6,
      "x": 0,
      "y": 36,
      "properties": {
        "region": "${var.region}",
        "title": "Lambda Throttles Across All",
        "metrics": [
          ["AWS/Lambda", "Throttles", {"stat": "Sum"}]
        ],
        "view": "timeSeries",
        "stacked": false,
        "period": 300
      }
    }
  ]
}

 EOF
}
