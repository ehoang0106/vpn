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

data "aws_ami" "vpn_ami" {
  most_recent = true
  filter {
    name = "product-code"
    #openvpn access server / self-hosted vpn (byol)
    #this is a product code for the openvpn access server ami
    values = ["f2ew2wrz425a1jagnifd02u5t"]
  }
  owners = ["aws-marketplace"]
}