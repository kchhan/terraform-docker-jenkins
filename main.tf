provider "aws" {
  region = "us-west-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

# The ec2 instance configuration
resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_pair_name
  subnet_id = aws_subnet.main.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.allow_tls.id]


  tags = {
    Name = var.instance_name
  }
}

# Create VPC for network access
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "ec2-jenkins"
  }
}

# Configure public subnet for VPC
# A subdivision of the network
resource "aws_subnet" "main" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  # indicates that instances launched should be assigned a public IP address
  map_public_ip_on_launch = true

  tags = {
    Name = "Main"
  }
}

# Create Internet Gateway to connect external traffic to VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# Create route table to route VPC traffic accordingly
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    # all traffic in internet should go through this gateway
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_route_table"
  }
}

# Associate route table with subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.public.id
}

# Security group to open network access
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "allow_tls"
  }
}

# Open SSH access
resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.allow_tls.id
  # to-do: use http provider to use only personal ip address
  # currently allow ssh from anywhere
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# Create a ssh keypair to connect with
# Use for dev environments, not production
# For production environment uses, create keypair outside of terraform
resource "tls_private_key" "ec2-controller-key" {
  algorithm = "ED25519"
}

# Connect the created ssh keypair with the instance
resource "aws_key_pair" "deployer" {
  key_name = "ec2-controller-key"
  public_key = tls_private_key.ec2-controller-key.public_key_openssh
}

# Save private key locally in repository
# Do not commit this file
resource "local_file" "ec2_controller_private_key" {
  content = tls_private_key.ec2-controller-key.private_key_openssh
  filename = "${path.module}/ec2-controller-private-key.pem"
  file_permission = "0400"
}