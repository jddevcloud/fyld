variable "project_name" {
  type = string
}

variable "env" {
  type = string
}

variable "size" {
  type    = string
  default = "cache.m6g.large"
}

variable "clusters" {
  type    = number
  default = 1
}

variable "cache_cluster_azs" {
  type = list(string)
  default = ["eu-west-1a",]
}

variable "port" {
  type    = number
  default = 6379
}


variable "nodes" {
  type    = number
  default = 1
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "security_groups" {
  type = list(string)
}
