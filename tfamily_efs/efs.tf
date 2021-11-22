terraform {
  required_version = ">= 0.12"
}

resource "aws_efs_file_system" "demoefs" {
  creation_token = "my-product"
  encrypted = true
  kms_key_id = "arn:aws:kms:ap-southeast-1:433567602443:key/2c614743-89b5-489b-a20f-5226a6cd6537"

  tags = {
    Owner = "Eason"
    Env   = "dev"
    Name  = "eason-demo"
  }
}

resource "aws_security_group" "eks_mtarget" {
  name        = "allow_efs"
  description = "Allow efs form 2049 port"
  vpc_id      = "${lookup(var.eks_vpc, "vpcid")}"

  ingress {
    description = "Allow from 2049 for EFS"
    from_port   = 2049
    to_port     = 2049
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
    Name = "eks_mtarget"
    Env = "dev"
    Owner = "eason"
  }
}


resource "aws_efs_mount_target" "demo_efs_mtarget1" {
  file_system_id = aws_efs_file_system.demoefs.id
  subnet_id      = "${lookup(var.eks_vpc, "subnet_prv")}"
  security_groups = [aws_security_group.eks_mtarget.id]
}

#resource "aws_efs_mount_target" "demo_efs_mtarget2" {
#  file_system_id = aws_efs_file_system.demoefs.id
#  subnet_id      = "${lookup(var.eks_vpc, "subnet_id2")}"
#  security_groups = [aws_security_group.eks_mtarget.id]
#}
#
#resource "aws_efs_mount_target" "demo_efs_mtarget3" {
#  file_system_id = aws_efs_file_system.demoefs.id
#  subnet_id      = "${lookup(var.eks_vpc, "subnet_id3")}"
#  security_groups = [aws_security_group.eks_mtarget.id]
#}

# ------ Outputs here
output "efs_id" {
  value = aws_efs_file_system.demoefs.id
}

output "mtarget1" {
  value = aws_efs_mount_target.demo_efs_mtarget1.id
}

#output "mtarget2" {
#  value = aws_efs_mount_target.demo_efs_mtarget2.id
#}
#
#output "mtarget3" {
#  value = aws_efs_mount_target.demo_efs_mtarget3.id
#}

