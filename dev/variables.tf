variable "ENV" {
  default = "dev"
}

variable "PROJECT_NAME" {}
variable "DEV_DB_USER" {}
variable "DEV_DB_PASSWORD" {}
variable "IDENTITY_ACCOUNT_ID" {}
variable "AWS_ASSUME_ROLE_ARN" {}
variable "SLACK_BOT_ACCESS_TOKEN" {}
variable "BOUNCER_PASSWORD" {}
variable "SNOWFLAKE_SYNC_PRIVATE_KEY" {}
variable "SNOWFLAKE_SYNC_PASSWORD" {}
variable "ECS_FYLD_BRAIN_CPU" {
  default = 2048
}
variable "ECS_FYLD_BRAIN_MEMORY" {
  default = 4096
}

variable "REDIS_SIZE" {
  type    = string
  default = "cache.t4g.micro"
}