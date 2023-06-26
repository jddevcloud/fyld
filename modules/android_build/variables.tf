data "aws_region" "current" {}

variable "project_name" {
  type = string
}

variable "env" {
  type = string
}
