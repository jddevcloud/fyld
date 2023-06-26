variable "ENV" {
  default = "production"
}

variable "PROJECT_NAME" {}
variable "PRODUCTION_DB_USER" {}
variable "PRODUCTION_DB_PASSWORD" {}
variable "PRODUCTION_REDSHIFT_PASSWORD" {}
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