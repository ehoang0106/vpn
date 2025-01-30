terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket = "terraform-state-khoahoang"
    key    = "terraform_state_vpn"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.region
}