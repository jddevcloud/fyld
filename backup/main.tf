terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "sitestream"

    workspaces {
      name = "backup"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.73.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

module "storage" {
  source = "../modules/backup_storage"
}

 