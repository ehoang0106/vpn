variable "instance_type" {
  default = "t2.micro"
  description = "instance type"
}

variable "ami_id" {
  default = "ami-056303ef214800fec"
}

variable "region" {
  default = "ap-southeast-2"
}

variable "instance_name" {
  default = "vpn-server"
}

variable "key_name" {
  default = "vpn-keypair"
  type = string
}

variable "subnet_name" {
  default = "vpn-subnet"
  type = string
}

variable "security_group_name" {
  default = "vpn-security-group"
  type = string
}

variable "vpc_name" {
  default = "vpn-vpc"
  type = string
}

