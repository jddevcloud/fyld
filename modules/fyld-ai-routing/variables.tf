variable "environment" {
  type = string
}

variable "subdomains" {}

variable "primary_domain_name" {
  type = string
}

variable "hosted_zone_domain" {
  type = string
}

variable "open_firebase_ips" {
  type    = list(string)
  default = []
}
