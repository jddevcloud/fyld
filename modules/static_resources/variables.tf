data "aws_region" "current" {}

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

variable "headers_lambda" {}