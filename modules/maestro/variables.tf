variable "project_name" {
  type = string
}

variable "env" {
  type = string
}

variable "cloudfront_domain_names" {
  type = list(string)
}

variable "primary_root_domain" {
  type = string
}

variable "acm_certificate_arn" {
  type = string
}

variable "domain_zone_id" {
  type = string
}

variable "cognito_user_pool_id" {
  type = string
}

variable "cognito_user_pool_client_id" {
  type = string
}

variable "waf_enabled" {
  type    = bool
  default = false
}

variable "waf_rate_limit" {
  type    = number
  default = 100
}

variable "log_bucket" {
  type = string
}

variable "dynamodb_connections_read_capacity" {
  type    = number
  default = 1
}
variable "dynamodb_connections_write_capacity" {
  type    = number
  default = 1
}
variable "dynamodb_connections_secondary_read_capacity" {
  type    = number
  default = 1
}
variable "dynamodb_connections_secondary_write_capacity" {
  type    = number
  default = 1
}
variable "dynamodb_nlp_metrics_hazards_read_capacity" {
  type    = number
  default = 1
}
variable "dynamodb_nlp_metrics_hazards_write_capacity" {
  type    = number
  default = 1
}
variable "dynamodb_nlp_metrics_controls_read_capacity" {
  type    = number
  default = 1
}
variable "dynamodb_nlp_metrics_controls_write_capacity" {
  type    = number
  default = 1
}
variable "backup_security_group_id" {
  type = string
}
variable "lambda_clamav_security_group_id" {
  type = string
}
variable "lambda_database_access_security_group_id" {
  type = string
}
variable "protected_subnet_ids" {
  type = list(string)
}
variable "fyld_brain_sqs_queue_arn" {
  type = string
}


variable "region" {
  type = string
  default = "eu-west-1"
}

variable "appautoscaling_target_read_connections_min_capacity" {
  type = number
  default = 1
}

variable "appautoscaling_target_read_connections_max_capacity" {
  type = number
  default = 100
}

variable "appautoscaling_target_write_connections_min_capacity" {
  type = number
  default = 5
}

variable "appautoscaling_target_write_connections_max_capacity" {
  type = number
  default = 100
}

variable "appautoscaling_target_read_connections_indexes_min_capacity" {
  type = number
  default = 1
}

variable "appautoscaling_target_read_connections_indexes_max_capacity" {
  type = number
  default = 100
}