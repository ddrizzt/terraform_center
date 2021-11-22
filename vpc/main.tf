terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region = var.aws_region
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "eaws"
}

resource "aws_vpc" "my_vpc" {
  cidr_block       = "10.1.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "EasonVPC"
    Env = "dev"
    Owner = "eason"
  }
}

resource "aws_subnet" "pub-1a" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.1.1.0/24"
  availability_zone = "ap-southeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "sb-pub-1a"
    Env = "dev"
    Owner = "eason"
  }
}

resource "aws_subnet" "pub-1b" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.1.2.0/24"
  availability_zone = "ap-southeast-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "sb-pub-1a"
    Env = "dev"
    Owner = "eason"
  }
}

resource "aws_subnet" "prv-1a" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.1.100.0/24"
  availability_zone = "ap-southeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "sb-prv-1a"
    Env = "dev"
    Owner = "eason"
  }
}


resource "aws_subnet" "prv-1b" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.1.101.0/24"
  availability_zone = "ap-southeast-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "sb-prv-1b"
    Env = "dev"
    Owner = "eason"
  }
}


resource "aws_internet_gateway" "my_vpc_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "igw-${aws_vpc.my_vpc.tags.Name}"
    Env = "dev"
    Owner = "eason"
  }
}

resource "aws_nat_gateway" "my_vpc_ngw" {
  connectivity_type = "private"
  subnet_id         = aws_subnet.prv-1b.id
}

resource "aws_route_table" "rtb-easonvpc_pub" {
    vpc_id = aws_vpc.my_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_vpc_igw.id
    }

    tags = {
    Name = "rtb-${aws_vpc.my_vpc.tags.Name}-internet"
    Env = "dev"
    Owner = "eason"
  }
}

resource "aws_route_table" "rtb-easonvpc_prv" {
    vpc_id = aws_vpc.my_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.my_vpc_ngw.id
    }

    tags = {
    Name = "rtb-${aws_vpc.my_vpc.tags.Name}-internal"
    Env = "dev"
    Owner = "eason"
  }
}

resource "aws_route_table_association" "rtba-pub-1a" {
    subnet_id = aws_subnet.pub-1a.id
    route_table_id = aws_route_table.rtb-easonvpc_pub.id
}

resource "aws_route_table_association" "rtba-pub-1b" {
    subnet_id = aws_subnet.pub-1b.id
    route_table_id = aws_route_table.rtb-easonvpc_pub.id
}

resource "aws_route_table_association" "rtba-prv-1a" {
    subnet_id = aws_subnet.prv-1b.id
    route_table_id = aws_route_table.rtb-easonvpc_prv.id
}

resource "aws_route_table_association" "rtba-prv-1b" {
    subnet_id = aws_subnet.prv-1b.id
    route_table_id = aws_route_table.rtb-easonvpc_prv.id
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh_sg"
  description = "Allow SSH/HTTP/HTTPS from public"
  vpc_id = aws_vpc.my_vpc.id

  dynamic "ingress" {
    for_each = var.ingress_rules_22_80_443
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
    Name = "sg-allow-22-80-443"
    Env = "dev"
    Owner = "eason"
  }
}

# ---- Output here ------
output "vpc-id" {
  value = aws_vpc.my_vpc.id
}

output "pub-1a" {
  value = aws_subnet.pub-1a.id
}

output "pub-1b" {
  value = aws_subnet.pub-1b.id
}

output "prv-1a" {
  value = aws_subnet.prv-1a.id
}

output "prv-1b" {
  value = aws_subnet.prv-1b.id
}


