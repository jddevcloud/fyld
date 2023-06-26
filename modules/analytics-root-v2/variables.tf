data "aws_region" "current" {}

# Naming
variable "project_name" {
  type = string
}

variable "env" {
  type = string
}

# Authentication
variable "username" {
  type = string
}

variable "password" {
  type = string
}

#network
variable "db_subnets" {
  type    = list(string)
  default = []
}
