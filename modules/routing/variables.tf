variable "environment" {
  type = string
}

variable "open_firebase_ips" {
  type    = list(string)
  default = []
}
