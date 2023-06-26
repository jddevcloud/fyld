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

variable "ftp_subnet" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "key_file" {
  type = string
}
