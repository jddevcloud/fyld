data "aws_region" "current" {}

# Naming
variable "project_name" {
  type = string
}

variable "env" {
  type = string
}

variable "service" {
  type = string
}

# Versioning
variable "engine_version" {
  type    = string
  default = "12.14"
}

variable "db_parameter_group_family" {
  type    = string
  default = "postgres12"
}

# Scaling
variable "encrypted_instance_type" {
  type    = string
  default = "db.t3.small"
}

# Authentication
variable "username" {
  type = string
}

variable "password" {
  type = string
}

#network
variable "domain_zone_id" {
  type = string
}

variable "bastion_subnet" {
  type = string
}

variable "db_subnets" {
  type    = list(string)
  default = []
}

variable "vpc_id" {
  type = string
}

variable "key_file" {
  type = string
}

variable "backup_retention_period" {
  type    = number
  default = 7
}

variable "multi_az" {
  type    = bool
  default = false
}

variable "allocated_storage" {
  type    = number
  default = 10
}

variable "snowflake_user_arn" {
  type    = string
  default = ""
}

variable "snowflake_external_id" {
  type    = string
  default = ""
}
