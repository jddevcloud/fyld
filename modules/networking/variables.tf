variable "project_name" {
  type = string
}

variable "env" {
  type = string
}

variable "private_subnets" {
  type = map
  default = {
    "eu-west-1a" : "10.0.144.0/20",
    "eu-west-1b" : "10.0.32.0/20",
    "eu-west-1c" : "10.0.16.0/20",
  }
}

variable "protected_subnets" {
  type = map
  default = {
    "eu-west-1a" : "10.0.112.0/20",
    "eu-west-1b" : "10.0.96.0/20",
    "eu-west-1c" : "10.0.128.0/20",
  }
}

variable "public_subnets" {
  type = map
  default = {
    "eu-west-1a" : "10.0.48.0/20",
    "eu-west-1b" : "10.0.64.0/20",
    "eu-west-1c" : "10.0.80.0/20",
  }
}

variable "region" {
  type = string
  default = "eu-west-1"
}
