# Terraform AWS Instance
This template creates an ec2 instance based on the latest security-hardened Centos7 image. 

Note that in the commons, the instance name is irrelevant. ec2 instances are namespaced by the aws instance profile. If you do not plan on assuming a role with the ec2 instance, the instance profile in this template is sufficient.
