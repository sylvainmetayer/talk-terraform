provider "aws" {
  region = var.region
}

terraform {
  required_providers {
    aws = {
      version = ">= 3.72.0"
      source  = "hashicorp/aws"
    }
  }
}

locals {
  prefix = "${var.app}"
  # https://www.terraform.io/docs/language/functions/index.html
  tags = merge(var.tags,
    {
      "environment" : terraform.workspace
  })
  instance_userdata = <<USERDATA
#!/bin/bash
sudo yum -y install openssh-server httpd
sudo systemctl enable --now sshd
sudo systemctl enable --now httpd
echo '${data.template_file.nginx_conf.rendered}' | sudo tee /var/www/html/index.html
USERDATA
}

data "aws_ami" "amazon" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

data "aws_vpc" "default" {
  default = true
}

data "template_file" "nginx_conf" {
  template = file("${path.module}/default.html.tpl")
  vars = {
    region    = var.region
    workspace = terraform.workspace
    app       = var.app
  }
}

resource "aws_key_pair" "user_key" {
  key_name   = "${local.prefix}-key"
  public_key = var.public_key
}

resource "aws_security_group" "ec2" {
  name        = "${local.prefix}-sg"
  description = "Allow HTTP + SSH inbound traffic"
  vpc_id      = data.aws_vpc.default.id
  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.tags,
    {
      "Name" : "${local.prefix}-sg"
      "cost:component" = "sg"
  })
}

resource "aws_instance" "web" {
  vpc_security_group_ids = [aws_security_group.ec2.id]
  key_name               = aws_key_pair.user_key.key_name

  ami                         = data.aws_ami.amazon.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true

  tags = merge(
    local.tags,
    {
      "Name" : "${local.prefix}-nginx"
      "cost:component" = "ec2"
  })
  user_data_base64 = base64encode(local.instance_userdata)

  lifecycle {
    ignore_changes = [user_data_base64]
  }
}

output "public_ip" {
  value = aws_instance.web.public_ip
}
