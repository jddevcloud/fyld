terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "sitestream"

    workspaces {
      name = "identity"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.73.0"
    }
  }
}

module "security_baseline" {
  source = "../modules/security_baseline"

  target_regions = ["eu-west-1", "us-east-1"]

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

data "aws_caller_identity" "current" {}

module "roles" {
  source              = "../modules/roles"
  identity_account_id = data.aws_caller_identity.current.account_id
}

module "iam_rotator" {
  source                 = "../modules/iam_rotator"
  project_name           = var.PROJECT_NAME
  env                    = var.ENV
  slack_bot_access_token = var.SLACK_BOT_ACCESS_TOKEN
}
