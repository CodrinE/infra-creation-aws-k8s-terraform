terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
    type = string
}

variable "cidr_block" {
  type = string
}

variable "key_name" {
    type = string
}

resource "tls_private_key" "devprivkey" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "local_file" "devkey" {
  content = tls_private_key.devprivkey.private_key_pem
  filename = "${path.module}/${var.key_name}.pem"
}

resource "aws_key_pair" "aws_key" {
    key_name   = var.key_name
    public_key = tls_private_key.devprivkey.public_key_openssh
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners = ["amazon"] # Canonical
}

resource "aws_iam_role" "test_role" {
  name = "test_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = "${aws_iam_role.test_role.name}"
}

resource "aws_iam_role_policy" "test_policy" {
  name = "test_policy"
  role = "${aws_iam_role.test_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
            "Effect": "Allow",
            "Action": "*",
            "Resource": "*"
     }
  ]
}
EOF
}

resource "aws_instance" "web" {
  ami             = data.aws_ami.amazon_linux.id
  instance_type   = "t2.micro" 
  key_name        = aws_key_pair.aws_key.key_name
  subnet_id = aws_subnet.dev-subnet-public-1.id
  vpc_security_group_ids = ["${aws_security_group.jenkins-sg.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.test_profile.name}"
  
  user_data       = "${file("install_jenkins.sh")}"
  associate_public_ip_address = true
  tags = {
    Name = "Jenkins"
    Environment = "dev"
    Area = "DevOps Infra"
  }
}

