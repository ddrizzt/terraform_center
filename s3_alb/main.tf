terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region = var.aws_region
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "eaws"
}

resource "aws_s3_bucket" "testing" {
  bucket = "eason6868testing"
}

resource "aws_s3_bucket_policy" "testing_p" {
  bucket = aws_s3_bucket.testing.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression's result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "MYBUCKETPOLICY"
    Statement = [
      {
        Sid       = "SID00123"
        Effect    = "Allow"
        Principal = {
          "Service" = "elasticloadbalancing.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.testing.arn}/*"
      },
    ]
  })
}
