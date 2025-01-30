#create a vpc
resource "aws_vpc" "vpn_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
}

#create a subnet
resource "aws_subnet" "vpn_subnet" {
  vpc_id     = aws_vpc.vpn_vpc.id
  cidr_block = "10.0.0.0/24"
}

#create a route table
resource "aws_route_table" "vpn_route_table" {
  vpc_id = aws_vpc.vpn_vpc.id
}

#create a internet gateway
resource "aws_internet_gateway" "vpn_internet_gateway" {
  vpc_id = aws_vpc.vpn_vpc.id
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

}

#create a network acl with inbout and outbound rules open to all traffic
resource "aws_network_acl" "vpn_network_acl" {
  vpc_id = aws_vpc.vpn_vpc.id

  #inbound rules
  ingress {
    protocol = "-1"
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    to_port = 0
  }

  #outbound rules

  egress {
    protocol = "-1"
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    to_port = 0
  }
}

#allocate a elastic ip
resource "aws_eip" "vpn_eip" {
  instance = aws_instance.vpn_server.id
}

# create a ec2 instance
resource "aws_instance" "vpn_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = aws_subnet.vpn_subnet.id
  vpc_security_group_ids = [aws_security_group.vpn_security_group.id]

  root_block_device {
    volume_size = 8
    delete_on_termination = true
  }
  tags = {
    Name = var.instance_name
  }

  #assign a elastic ip to the instance
  associate_public_ip_address = true
  
}