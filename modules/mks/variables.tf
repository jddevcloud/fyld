variable "SNOWFLAKE_SYNC_PRIVATE_KEY" {}
variable "SNOWFLAKE_SYNC_PASSWORD" {}

variable "project_name" {
  type = string
}

variable "env" {
  type = string
}

variable "size" {
  type    = string
  default = "kafka.t3.small"
}

variable "volume_size" {
  type    = string
  default = 100
}

variable "subnet_ids" {
    type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "host_subnet_id" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}

variable "db_host" {
  type = string
}

variable "database_sg" {
  type = string
}

