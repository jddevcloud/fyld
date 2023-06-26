resource "random_id" "target_group_sufix" {
  byte_length = 2
}

# Project level
variable "project_name" {}
variable "env" {}

# Networking
variable "vpc_id" {}
variable "public_subnets" {}
variable "protected_subnets" {}
# variable "db_address" {}

# ECR
variable "repository_url" {}

# EC2
variable "ecs_instance_max_size" {
  default = 4
}
variable "ecs_instance_min_size" {
  default = 2
}
variable "ecs_instance_desired_capacity" {
  default = 2
}
variable "ecs_instance_type" {
  default = "t4g.small"
}


# ECS
variable "container_port" {
  default = 8000
}

variable "ecs_task_count" {
  default = 4
}

variable "deployment_maximum_percent" {
  default = 100
}

variable "deployment_minimum_healthy_percent" {
  default = 50
}

variable "health_check_grace_period_seconds" {
  default = 0
}

variable "ecs_scaling_max_capacity" {
  default = 4
}
variable "ecs_scaling_min_capacity" {
  default = 2
}
variable "ecs_scaling_target_capacity" {
  default = 2
}

variable "lb_certificate_arn" {}
variable "cf_certificate_arn" {}

variable "domain_zone_id" {}
variable "domain_names" {}
variable "primary_root_domain" {}

variable "database_security_group" {}
variable "elastiache_security_group" {}

variable "waf_enabled" {
  type    = bool
  default = false
}

variable "waf_rate_limit" {
  type    = number
  default = 600
}

variable "cloudfront_custom_header" {
  default = "ybR59hXmgAxbGjC4"
}

variable "region" {
  type = string
  default = "eu-west-1"
}
