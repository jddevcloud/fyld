locals {
  is_master_account = var.account_type == "master"
}

data "aws_caller_identity" "current" {
}

resource "aws_iam_user" "contact_support" {
  name = "ContactSupport"
}

data "aws_organizations_organization" "org" {}

module "secure_baseline" {
  source = "github.com/sitestream/terraform-aws-secure-baseline?ref=9b2c7107d416ce49bfe8ceb254f360df40d8ade6"

  account_type                         = var.account_type
  audit_log_bucket_name                = var.audit_s3_bucket_name
  aws_account_id                       = data.aws_caller_identity.current.account_id
  guardduty_disable_email_notification = true
  master_account_id                    = local.is_master_account ? "" : data.aws_organizations_organization.org.master_account_id
  member_accounts                      = var.member_accounts
  region                               = var.region
  support_iam_role_principal_arns      = [aws_iam_user.contact_support.arn]
  use_external_audit_log_bucket        = local.is_master_account ? false : true
  target_regions                       = var.target_regions

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
