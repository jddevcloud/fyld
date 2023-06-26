variable "ENV" {
  default = "root"
}

variable "PROJECT_NAME" {}

variable "MEMBER_ACCOUNTS" {
  default = [
    {
      account_id = "382647213807"
      email      = "sysops+identity@sitestream.app"
    },
    {
      account_id = "116977071601"
      email      = "sysops+staging@sitestream.app"
    },
    {
      account_id = "734907094745"
      email      = "sysops+production@sitestream.app"
    },
    {
      account_id = "439717252254"
      email      = "sysops+sme@fyld.ai"
    },
    {
      account_id = "459748531150"
      email      = "sysops+dev@fyld.ai"
    },
    {
      account_id = "870135445827"
      email      = "sysops+sme-usa@fyld.ai"
    }
  ]
}

variable "IDENTITY_ACCOUNT_ID" {}
variable "SLACK_WEBHOOK_URL" {}

variable "BILLING_THRESHOLD" {
  default = 10
}

variable "AWS_ASSUME_ROLE_ARN" {}
variable "SLACK_BOT_ACCESS_TOKEN" {}
variable "ROOT_DB_USER" {}
variable "ROOT_ANALYTICS_PASSWORD" {}

# Get below params from snowflake: "DESC INTEGRATION analytics_segment;"
variable "snowflake_user_arn" {
  type    = string
  default = "arn:aws:iam::112500408651:user/henw-s-ukst1266"
}

variable "snowflake_external_id" {
  type    = string
  default = "KQ33960_SFCRole=3_QwG5KY+2xBRwWwSzHxwyWJ1dYVs="
}

variable "segment_workspace_id" {
  type    = string
  default = "KVYZH7EsQP"
}