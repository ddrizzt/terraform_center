##Overview
Create a new APIGateway and using lambda do the authorization. And proxy to an internal NLB in VPC. This need create a VPC link in API Gateway and NLB before you run this.

###Steps:
terraform init

terraform plan

terraform apply -auto-approve

###Destroy
terraform destroy -auto-approve

