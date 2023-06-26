
terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.73.0"
    }
    archive = {
      source = "hashicorp/archive"
    }
    template = {
      source = "hashicorp/template"
    }
  }
}
