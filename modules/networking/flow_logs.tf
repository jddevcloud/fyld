locals {
  vpc_iam_role_name         = "${var.project_name}-${var.env}-VPC-Flow-Logs-Publisher"
  vpc_iam_role_policy_name  = "${var.project_name}-${var.env}-VPC-Flow-Logs-Publish-Policy"
  vpc_log_group_name        = "${var.project_name}-${var.env}-vpc-flow-logs"
  vpc_log_retention_in_days = 365
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = local.vpc_log_group_name
  retention_in_days = local.vpc_log_retention_in_days

  tags = {
    Name        = "${var.project_name}-${var.env}"
    Environment = var.env
    Project     = var.project_name
  }
}

resource "aws_flow_log" "vpc_flow_logs" {
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn
  iam_role_arn    = aws_iam_role.vpc_flow_logs_publisher.arn
  vpc_id          = aws_vpc.vpc.id
  traffic_type    = "ALL"
}

data "aws_iam_policy_document" "vpc_flow_logs_publisher_assume_role_policy" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "vpc_flow_logs_publisher" {
  name               = local.vpc_iam_role_name
  assume_role_policy = data.aws_iam_policy_document.vpc_flow_logs_publisher_assume_role_policy.json

  tags = {
    Name        = "${var.project_name}-${var.env}"
    Environment = var.env
    Project     = var.project_name
  }
}

data "aws_iam_policy_document" "vpc_flow_logs_publish_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "vpc_flow_logs_publish_policy" {
  name = local.vpc_iam_role_policy_name
  role = aws_iam_role.vpc_flow_logs_publisher.id

  policy = data.aws_iam_policy_document.vpc_flow_logs_publish_policy.json
}
