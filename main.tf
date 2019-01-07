data "template_file" "user_data" {
  template = "${file("${path.module}/userdata.sh")}"

  vars {
    ssh_authorized_key = "${var.ssh_authorized_key}"
  }
}

# resource "aws_iam_instance_profile" "namespaced_profile" {
#   name  = "${var.namespace}-instance-profile"
#   role = "lstm-ec2-instance-role"
# }

# resource "aws_iam_role" "role" {
#   name = "${var.namespace}-instance-role"
#   path = "/"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "sts:AssumeRole",
#       "Principal": {
#          "Service": "ec2.amazonaws.com.cn"
#       },
#       "Effect": "Allow",
#       "Sid": ""
#     }
#   ]
# }
# EOF
# }

resource "aws_instance" "ec2" {
  ami           = "${var.ami_name}"
  instance_type = "${var.instance_type}"
  key_name      = "${var.namespace}-${var.environment}-key-pair"

  vpc_security_group_ids = "${var.vpc_security_group_ids}"
  subnet_id              = "${var.subnet_id}"
  # iam_instance_profile   = "${aws_iam_instance_profile.namespaced_profile.name}"
  iam_instance_profile = "${var.namespace}-instance-profile"
  user_data              = "${data.template_file.user_data.rendered}"

  tags = "${merge(map(
    "Requestor", "${var.requestor}",
    "Department", "${var.department}",
    "AppId", "${var.app_id}",
    "AppName", "${var.app_name}",
    "CostCenter", "${var.cost_center}",
    "ProjectCode", "${var.project_code}",
    "DataClass", "${var.data_class}",
    "Environment", "${var.environment}",
  ), var.extra_tags)}"
}

output "instance_id" {
  value = "${aws_instance.ec2.id}"
}