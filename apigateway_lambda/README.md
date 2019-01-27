##Overview
Create a new APIGateway and using lambda do the authorization. And proxy to http://petstore-demo-endpoint.execute-api.com/petstore/pets/{proxy}

###Steps:
terraform init

terraform plan

terraform apply -auto-approve

###Destroy
terraform destroy -auto-approve

