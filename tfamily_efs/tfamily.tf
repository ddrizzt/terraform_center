terraform {
  required_version = ">= 0.12"
}

locals {
  efs_id = aws_efs_file_system.demoefs.id
}

resource "aws_transfer_server" "sftp_demo1" {
  endpoint_type = "VPC"
  endpoint_details {
    subnet_ids = ["${lookup(var.eks_vpc, "subnet_pub")}"]
    vpc_id     = "${lookup(var.eks_vpc, "vpcid")}"
    address_allocation_ids = [aws_eip.eip_tfamily_sftp.id]
    security_group_ids = [aws_security_group.tfamily_sftp_pub.id]
  }

  identity_provider_type = "SERVICE_MANAGED"
  security_policy_name = "TransferSecurityPolicy-2020-06"
  protocols   = ["SFTP"]
  directory_id = ""
  domain = "EFS"

  tags = {
    Name = "tfamily-sftp-demo01"
    Env = "dev"
    Owner = "Eason"
  }
}

resource "aws_transfer_user" "eason" {
  server_id = aws_transfer_server.sftp_demo1.id
  user_name = "eason"
  role = aws_iam_role.tf_sftp_demo1.arn
  home_directory = "/${local.efs_id}/eason"
  posix_profile {
    gid = 1000
    uid = 1000
  }
}

resource "aws_transfer_ssh_key" "tf_sftp_demo1_user_eason" {
  server_id = aws_transfer_server.sftp_demo1.id
  user_name = aws_transfer_user.eason.user_name
  body      = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDH7GB2N5SIl5mlJj8HzaB4XJFIxNfKnjb58dylDO5rDA5d0ogHf4wx8F1Ih3qMn7EzE4u6Hq4dpTTCn1rKoUhMdgBE5DOa3T9qnzHkwbVKzNonC7it2n5B6St1mldmd2/kGUQJHiREFagwkkWkgvSdqqbgv5otd178Q+eTjsHWVFozKWQ1ey6Gu1eLoI4k+DAepe1X9TLgJ9qM7QNpGKgoKC8vYNpxk9kz+r4sbUCMyFBI/zWswjGeizhMzrHjq9v0HhuPntE9hg8s43J5uRXN3ESZcmo36kAm1Zp2OMKUfRWVvNkk8A+EmqD19RDz/nDoGSTFh1Rd3qPxr/94VRYVWMqbZo8z+jyHyFZELyyn3u8dEohb+k0Xktg+WcSb0PkurUBok/3NP9KmPsGqrrK3xejuOGcbsIkZpK3rPcoKPSULMHgaydjISgLwoU6f+LpB7qHw4mjzZ8wuoRvWrxhG/L3rJk4R7+mlk+ohN2lrLNEwVDwtPzFWmKdv6Et+PMc= efsdemo"
}

# ------ Sub resource definition....
resource "aws_security_group" "tfamily_sftp_pub" {
  name        = "allow_sftp_pub"
  description = "Allow sftp accession from internet for transfer family"
  vpc_id      = "${lookup(var.eks_vpc, "vpcid")}"

  ingress {
    description = "Allow from port for SFTP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${lookup(var.eks_vpc, "cidr")}"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "tfamily_sftp_pub"
    Env = "dev"
    Owner = "Eason"
  }
}

resource "aws_eip" "eip_tfamily_sftp" {
  vpc = true
  tags = {
    Name = "tfmaily_sftp_eip"
    Env = "dev"
    Owner = "Eason"
  }
}

resource "aws_iam_role" "tf_sftp_demo1" {
  name = "tf-test-transfer-user-iam-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "transfer.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "tf_sftp_demo1" {
  name = "tf-test-transfer-user-iam-policy"
  role  = aws_iam_role.tf_sftp_demo1.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowFullAccesstoS3",
            "Effect": "Allow",
            "Action": [
                "elasticfilesystem:*"
            ],
            "Resource": "*"
        }
    ]
}
POLICY
}

# ------ Outputs here
output "sftp_id" {
  value = aws_transfer_server.sftp_demo1.id
}

output "sftp_endpoint" {
  value = aws_transfer_server.sftp_demo1.endpoint
}

output "sftp_user" {
  value = aws_transfer_user.eason.arn
}

output "security_sfp" {
  value = aws_security_group.tfamily_sftp_pub.id
}



