locals {
  metric_name = [
    "UnauthorizedAPICalls",
    "NoMFAConsoleSignin",
    "RootUsage",
    "IAMChanges",
    "CloudTrailCfgChanges",
    "ConsoleSigninFailures",
    "DisableOrDeleteCMK",
    "S3BucketPolicyChanges",
    "AWSConfigChanges",
    "SecurityGroupChanges",
    "NACLChanges",
    "NetworkGWChanges",
    "RouteTableChanges",
    "VPCChanges",
  ]
  metric_namespace = "CISBenchmark"

  individual_widget_format = <<EOF
{
  "type":"metric",
  "x":%v,
  "y":%v,
  "width":12,
  "height":6,
  "properties":{ "metrics":[[ "${local.metric_namespace}", "%v" ]],
    "period":300,
    "stat":"Sum",
    "region":"eu-west-1",
    "title":"%v"
  }
}
EOF

  layout_x = [0, 12, 0, 12, 0, 12, 0, 12, 0, 12, 0, 12, 0, 12]
  layout_y = [0, 0, 7, 7, 15, 15, 22, 22, 29, 29, 36, 36, 43, 43]
}

resource "aws_iam_role" "admin" {
  name = "Admin"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Principal": {
      "AWS": "arn:aws:iam::${var.IDENTITY_ACCOUNT_ID}:root"
    },
    "Action": "sts:AssumeRole",
    "Condition": {"Bool": {"aws:MultiFactorAuthPresent": "true"}}
  }
}
EOF
}

resource "aws_iam_role_policy_attachment" "admin" {
  role       = aws_iam_role.admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role" "security" {
  name = "SecurityAuditor"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Principal": {
      "AWS": "arn:aws:iam::${var.IDENTITY_ACCOUNT_ID}:root"
    },
    "Action": "sts:AssumeRole",
    "Condition": {"Bool": {"aws:MultiFactorAuthPresent": "true"}}
  }
}
EOF
}

resource "aws_iam_role_policy_attachment" "security" {
  role       = aws_iam_role.security.name
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

module "security_baseline" {
  source          = "../modules/security_baseline"
  account_type    = "master"
  member_accounts = var.MEMBER_ACCOUNTS

  target_regions = [
    "eu-west-1",
    "us-east-1",
  ]

  providers = {
    aws                = aws
    aws.ap-northeast-1 = aws.ap-northeast-1
    aws.ap-northeast-2 = aws.ap-northeast-2
    aws.ap-south-1     = aws.ap-south-1
    aws.ap-southeast-1 = aws.ap-southeast-1
    aws.ap-southeast-2 = aws.ap-southeast-2
    aws.ca-central-1   = aws.ca-central-1
    aws.eu-central-1   = aws.eu-central-1
    aws.eu-north-1     = aws.eu-north-1
    aws.eu-west-1      = aws.eu-west-1
    aws.eu-west-2      = aws.eu-west-2
    aws.eu-west-3      = aws.eu-west-3
    aws.sa-east-1      = aws.sa-east-1
    aws.us-east-1      = aws.us-east-1
    aws.us-east-2      = aws.us-east-2
    aws.us-west-1      = aws.us-west-1
    aws.us-west-2      = aws.us-west-2
  }
}

resource "aws_cloudwatch_event_rule" "cis_to_slack" {
  name        = "AutomaticFailedSecurityHubFindingsToSlack"
  description = "Automatically send failed security hub findings to Slack"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.securityhub"
  ],
  "detail-type": [
    "Security Hub Findings - Imported"
  ],
  "detail": {
    "findings": {
      "Compliance": {
        "Status": [
          "FAILED"
        ]
      }
    }
  }
}
PATTERN
}

data "aws_lambda_function" "security_hub_lambda" {
  function_name = "EnableSecurityHubFindingsToS-lambdafindingsToSlack-PHYXVAESY01K"
}

resource "aws_cloudwatch_event_target" "sns" {
  rule      = aws_cloudwatch_event_rule.cis_to_slack.name
  target_id = "SecurityHubFindingsToSlack"
  arn       = data.aws_lambda_function.security_hub_lambda.arn
}


resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "CISBenchmark_Statistics_Combined"
  dashboard_body = <<EOF
 {
   "widgets": [
       {
          "type":"metric",
          "x":0,
          "y":0,
          "width":20,
          "height":16,
          "properties":{
             "metrics":[
               ${join(",", formatlist("[ \"${local.metric_namespace}\", \"%v\" ]", local.metric_name))}
             ],
             "period":300,
             "stat":"Sum",
             "region":"eu-west-1",
             "title":"CISBenchmark Statistics"
          }
       }
   ]
 }
 EOF
}

resource "aws_cloudwatch_dashboard" "main_individual" {
  dashboard_name = "CISBenchmark_Statistics_Individual"

  dashboard_body = <<EOF
{
  "widgets": [
    ${join(",", formatlist(local.individual_widget_format, local.layout_x, local.layout_y, local.metric_name, local.metric_name))}
  ]
}
 EOF
}
