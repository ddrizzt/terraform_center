variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "ap-southeast-1"
}


variable "ingress_rules" {
  default     = {
    "rule-ssh" = {
      "description" = "For SSH"
      "from_port"   = "22"
      "to_port"     = "22"
      "protocol"    = "tcp"
      "cidr_blocks" = ["0.0.0.0/0"]
    }
  }
  type        = map(any)
  description = "Security group rules"
}

