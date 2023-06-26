data "aws_region" "current" {}

# Naming
variable "project_name" {
  type = string
}

variable "env" {
  type = string
}
#network
variable "domain_zone_id" {
  type = string
}

variable "pgbouncer_subnet" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "key_file" {
  type = string
}

variable "db_password" {
  type = string
}

variable "db_host" {
  type = string
}

variable "bouncer_password" {
  type = string
}

variable "database_security_group" {}