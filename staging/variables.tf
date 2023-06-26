variable "ENV" {
  default = "staging"
}

variable "PROJECT_NAME" {}
variable "STAGING_DB_USER" {}
variable "STAGING_DB_PASSWORD" {}
variable "IDENTITY_ACCOUNT_ID" {}
variable "AWS_ASSUME_ROLE_ARN" {}
variable "SLACK_BOT_ACCESS_TOKEN" {}
variable "BOUNCER_PASSWORD" {}
variable "SNOWFLAKE_SYNC_PRIVATE_KEY" {}
variable "SNOWFLAKE_SYNC_PASSWORD" {}
variable "ECS_FYLD_BRAIN_CPU" {
  default = 8192
}
variable "ECS_FYLD_BRAIN_MEMORY" {
  default = 16384
}
variable "REDIS_SIZE" {
  type    = string
  default = "cache.t4g.micro"
}