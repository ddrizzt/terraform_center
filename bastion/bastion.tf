
terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region = var.aws_region
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "eaws"
}



resource "aws_key_pair" "bastionkey" {
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDH7GB2N5SIl5mlJj8HzaB4XJFIxNfKnjb58dylDO5rDA5d0ogHf4wx8F1Ih3qMn7EzE4u6Hq4dpTTCn1rKoUhMdgBE5DOa3T9qnzHkwbVKzNonC7it2n5B6St1mldmd2/kGUQJHiREFagwkkWkgvSdqqbgv5otd178Q+eTjsHWVFozKWQ1ey6Gu1eLoI4k+DAepe1X9TLgJ9qM7QNpGKgoKC8vYNpxk9kz+r4sbUCMyFBI/zWswjGeizhMzrHjq9v0HhuPntE9hg8s43J5uRXN3ESZcmo36kAm1Zp2OMKUfRWVvNkk8A+EmqD19RDz/nDoGSTFh1Rd3qPxr/94VRYVWMqbZo8z+jyHyFZELyyn3u8dEohb+k0Xktg+WcSb0PkurUBok/3NP9KmPsGqrrK3xejuOGcbsIkZpK3rPcoKPSULMHgaydjISgLwoU6f+LpB7qHw4mjzZ8wuoRvWrxhG/L3rJk4R7+mlk+ohN2lrLNEwVDwtPzFWmKdv6Et+PMc= bastion"
}


resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh_sg"
  description = "Allow SSH/HTTP/HTTPS from public"
  vpc_id = "vpc-c526eea3"

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      description      = lookup(ingress.value, "description", null)
      from_port        = lookup(ingress.value, "from_port", null)
      to_port          = lookup(ingress.value, "to_port", null)
      protocol         = lookup(ingress.value, "protocol", null)
      cidr_blocks      = lookup(ingress.value, "cidr_blocks", null)
    }
  }

  egress {
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-allow-22"
    Env = "dev"
  }
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "bastion-node"

  ami                    = "ami-024221a59c9020e72"
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.bastionkey.key_name
  monitoring             = false
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  subnet_id              = "subnet-ef0aa7a7"

  tags = {
    Name   = "bastion-node"
    Environment = "dev"
  }
}

