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

# ECS

variable "ecs_task_count" {
  default = 1
}

variable "deployment_maximum_percent" {
  default = 200
}

variable "deployment_minimum_healthy_percent" {
  default = 50
}

variable "health_check_grace_period_seconds" {
  default = 0
}

variable "fallback_capacity_provider" {
  type = string
  default = "FARGATE"
}

variable "database_security_group" {}
variable "elastiache_security_group" {}

variable "region" {
  type = string
  default = "eu-west-1"
}

variable "cpu" {
  default = 2048
}
variable "memory" {
  default = 4096
}