variable "aws_region" {
  default = "cn-north-1"
}

variable "subnet_id" {
  default = "subnet-0fbc186b"
}

variable "vpc_security_group_ids" {
  description = "ist of secgroup ids to attach to the instance"
  default = []
}

variable "ami_name" {
  description = "EC2 AMI Name"
  type = "string"
}

variable "instance_type" {
  description = "Instance Type"
}

variable "key_name" {
  type = "string"
  default = "dci-carrier-gateway"
  description = "ssh keypair to use for the aws instances. Optional."
}

variable "ssh_authorized_key" {
  type = "string"
  default = ""
  description = "an additional keypair for ec2-user ssh_authorized_key"
}

// The following several variables are used in tagging.
// Please see https://nike.sharepoint.com/teams/na27/DataAnalytics/Data%20Quality/Cloud/Cloud%20Tagging%20Strategy%20Proposal.%20v1.8.docx?d=wc070d66a4ca746e194d00b7c121c6e55
// for up-to-date tagging standards
variable "namespace" {
  description = "entsvcs-provided AWS namespace"
  type = "string"
}

variable "app_name" {
  description = "application name"
  type = "string"
}

variable "environment" {
  description = "environment"
  type = "string"
}

variable "requestor" {
  description = "requestor's email address or main distribution list"
  type = "string"
}

variable "department" {
  description = "the name of the group that is responsible for the Cloud resource"
  type = "string"
}

variable "app_id" {
  description = ""
  default = ""
  type = "string"
}

variable "cost_center" {
  description = "6-digit cost center code"
  type = "string"
}

variable "project_code" {
  description = "Nike project code or KLO"
  type = "string"
}

variable "data_class" {
  description = <<EOF
Data Classification - choose from:
Confidential (previously platinum and gold)
Restricted (previously silver and bronze)
Public
EOF

  type = "string"
}

variable "extra_tags" {
  description = "Extra tags to be applied to created resources."
  type = "map"
  default = {}
}