variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "ap-southeast-1"
}

provider "aws" {
  region = var.aws_region
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "eaws"
}

variable "eks_vpc" {
  type = map

  default = {
    vpcid = "vpc-0383480aa5e5b4372"
    cidr = "0.0.0.0/0"
    subnet_pub = "subnet-0a15057c0d62a0bbc"
    subnet_prv = "subnet-0f8842b30d9cb5773"
#    subnet_id2 = "subnet-0145622191a3eedd7"
#    subnet_id3 = "subnet-02646a150ec34bb55"
  }
}



