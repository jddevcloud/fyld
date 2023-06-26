variable "audit_s3_bucket_name" {
  description = "The name of the S3 bucket to store various audit logs."
  default     = "sitestream-audit"
}

variable "region" {
  description = "The AWS region in which global resources are set up."
  default     = "eu-west-1"
}

variable "account_type" {
  description = "A list of regions to set up with this module."
  default     = "member"
}

variable "member_accounts" {
  description = "A list of regions to set up with this module."
  default     = []
}

variable "target_regions" {
  description = "A list of regions to set up with this module."
  default     = []
}
