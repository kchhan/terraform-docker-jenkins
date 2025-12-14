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

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_pair_name

  tags = {
    Name = var.instance_name
  }
}

# Create a ssh keypair to connect with
# Use for dev environments, not production
# For production environment uses, create keypair outside of terraform
resource "tls_private_key" "ec2-controller-key" {
  algorithm = "ED25519"
}

# Connect the created ssh keypair with the instance
resource "aws_key_pair" "deployer" {
  key_name = "ec2-controller-ssh"
  public_key = tls_private_key.ec2-controller-key.public_key_openssh
}

# Save private key locally in repository
# Do not commit this file
resource "local_file" "ec2_private_key" {
  content = tls_private_key.ec2-controller-key.private_key_pem
  filename = "${path.module}/ec2-controller-private-key.pem"
  file_permission = "0400"
}