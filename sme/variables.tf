variable "ENV" {
  default = "sme"
}

variable "PROJECT_NAME" {}
variable "SME_DB_USER" {}
variable "SME_DB_PASSWORD" {}
variable "IDENTITY_ACCOUNT_ID" {}
variable "AWS_ASSUME_ROLE_ARN" {}
variable "SLACK_BOT_ACCESS_TOKEN" {}
variable "BOUNCER_PASSWORD" {}
variable "SNOWFLAKE_SYNC_PRIVATE_KEY" {}
variable "SNOWFLAKE_SYNC_PASSWORD" {}
variable "ECS_FYLD_BRAIN_CPU" {
  default = 16384
}
variable "ECS_FYLD_BRAIN_MEMORY" {
  default = 32768
}