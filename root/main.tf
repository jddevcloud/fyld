terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "sitestream"

    workspaces {
      name = "root"
    }
  }
}


module "roles" {
  source              = "../modules/roles"
  identity_account_id = var.IDENTITY_ACCOUNT_ID
}

module "cis_alarm" {
  source  = "terraform-aws-modules/notify-slack/aws"
  version = "2.10"

  create_sns_topic     = false
  slack_webhook_url    = var.SLACK_WEBHOOK_URL
  slack_channel        = "sysops-alerts"
  slack_username       = "CIS Alarm"
  lambda_description   = "Lambda function which sends CISAlarms to Slack"
  sns_topic_name       = "CISAlarm"
  lambda_function_name = "cis_alarm_lambda"

  tags = {
    Name        = "${var.PROJECT_NAME}-${var.ENV}-cis-alerts-to-slack"
    Environment = var.ENV
    Project     = var.PROJECT_NAME
  }
}

module "billing_alert_lambda" {
  source  = "terraform-aws-modules/notify-slack/aws"
  version = "2.10"

  create_sns_topic     = false
  slack_webhook_url    = var.SLACK_WEBHOOK_URL
  slack_channel        = "sysops-alerts"
  slack_username       = "Billing Alert"
  lambda_description   = "Lambda function which sends billing threshold alert to Slack"
  sns_topic_name       = aws_sns_topic.sns_alert_topic.name
  lambda_function_name = "billing_alert_lambda"

  providers = {
    aws = aws.us-east-1
  }

  tags = {
    Name        = "${var.PROJECT_NAME}-${var.ENV}-config-changes-to-slack"
    Environment = var.ENV
    Project     = var.PROJECT_NAME
  }
}

resource "aws_sns_topic" "sns_alert_topic" {
  name = "billing-alarm-notification-gbp-root"

  provider = aws.us-east-1
}

resource "aws_cloudwatch_metric_alarm" "consolidated_accounts_billing_alarm_to_new_sns" {
  alarm_name          = "account-billing-alarm-gbp-root"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = "28800"
  statistic           = "Maximum"
  alarm_description   = "Billing consolidated alarm >= GBP£ 10"
  threshold           = "10"
  alarm_actions       = [aws_sns_topic.sns_alert_topic.arn]

  provider = aws.us-east-1

  dimensions = {
    Currency = "GBP"
  }
}

module "iam_rotator" {
  source                 = "../modules/iam_rotator"
  project_name           = var.PROJECT_NAME
  env                    = var.ENV
  slack_bot_access_token = var.SLACK_BOT_ACCESS_TOKEN
}

module "analyticsv2" {
  source                  = "../modules/analytics-root-v2"
  project_name            = var.PROJECT_NAME
  env                     = var.ENV
  username                = var.ROOT_DB_USER
  password                = var.ROOT_ANALYTICS_PASSWORD # Only printable ASCII characters besides '/', '@', '"', ' ' may be used.
}