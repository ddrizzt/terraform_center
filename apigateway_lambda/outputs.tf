output "apigateway_pubisherURL" {
  value = "${aws_api_gateway_deployment.apigw_deployment.invoke_url}"
}

output "apigateway_name" {
  value = "${aws_api_gateway_rest_api.apigateway.name}"
}

output "lambda_name" {
  value = "${aws_lambda_function.lambda.function_name}"
}
