#create a vpc
resource "aws_vpc" "vpn_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = var.vpc_name
  }
}

#create a subnet
resource "aws_subnet" "vpn_subnet" {
  vpc_id     = aws_vpc.vpn_vpc.id
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = var.subnet_name
  }
}

#associate the subnet with the route table
resource "aws_route_table_association" "vpn_route_table_association" {
  subnet_id      = aws_subnet.vpn_subnet.id
  route_table_id = aws_route_table.vpn_route_table.id
}

#create a route table
resource "aws_route_table" "vpn_route_table" {
  vpc_id = aws_vpc.vpn_vpc.id

  #route to internet gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpn_internet_gateway.id
  }

  tags = {
    Name = "vpn-route-table"
  }
}

#create a internet gateway
resource "aws_internet_gateway" "vpn_internet_gateway" {
  vpc_id = aws_vpc.vpn_vpc.id

  tags = {
    Name = "vpn-internet-gateway"
  }
}

#create a security group
resource "aws_security_group" "vpn_security_group" {
  vpc_id = aws_vpc.vpn_vpc.id

  #inbound rules
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 943
    to_port     = 943
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 945
    to_port     = 945
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #outbound rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.security_group_name
  }
}

#create a network acl with inbout and outbound rules open to all traffic
resource "aws_network_acl" "vpn_network_acl" {
  vpc_id = aws_vpc.vpn_vpc.id

  #inbound rules
  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  #outbound rules

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "vpn-network-acl"
  }
}

#allocate a elastic ip
resource "aws_eip" "vpn_eip" {
  instance = aws_instance.vpn_server.id
}

#print out the ec2 name, subnet name, security group name, vpc name, elastic ip
output "ec2_name" {
  value = aws_instance.vpn_server.tags.Name
}

output "subnet_name" {
  value = aws_subnet.vpn_subnet.tags.Name
}

output "security_group_name" {
  value = aws_security_group.vpn_security_group.tags.Name
}

output "vpc_name" {
  value = aws_vpc.vpn_vpc.tags.Name
}

output "elastic_ip" {
  value = aws_eip.vpn_eip.public_ip
}

#output ami id
output "ami_id" {
  value = data.aws_ami.vpn_ami.id
}

# create a ec2 instance
resource "aws_instance" "vpn_server" {
  ami                    = data.aws_ami.vpn_ami.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.vpn_subnet.id
  vpc_security_group_ids = [aws_security_group.vpn_security_group.id]

  root_block_device {
    volume_size           = 8
    delete_on_termination = true
  }
  tags = {
    Name = var.instance_name
  }

  #assign a elastic ip to the instance
  associate_public_ip_address = true

}