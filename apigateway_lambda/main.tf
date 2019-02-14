# Specify the provider and access details
provider "aws" {
  profile = "${var.profile}"
  skip_credentials_validation = true
  skip_metadata_api_check = true
  #shared_credentials_file = "~/.aws/credentials"
  shared_credentials_file = "%UserProfile%/.aws/credentials"
  region = "${var.region}"
}

provider "archive" {}

data "archive_file" "zip" {
  type = "zip"
  source_file = "lambda_apigw.py"
  output_path = "lambda_apigw.zip"
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "policy" {
  version = "2012-10-17"

  statement {
    sid = ""
    effect = "Allow"

    principals {
      identifiers = [
        "lambda.amazonaws.com"]
      type = "Service"
    }

    actions = [
      "sts:AssumeRole"]
  }
}

resource "random_string" "gwsuffix" {
  length = 6
  upper = false
  lower = true
  number = true
  special = false
}

resource "random_integer" "state_id" {
  min = 10000
  max = 99999
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda_${random_string.gwsuffix.result}"
  assume_role_policy = "${data.aws_iam_policy_document.policy.json}"
}

resource "aws_lambda_function" "lambda" {
  function_name = "apigw_${random_string.gwsuffix.result}"

  filename = "${data.archive_file.zip.output_path}"
  source_code_hash = "${data.archive_file.zip.output_base64sha256}"

  role = "${aws_iam_role.iam_for_lambda.arn}"
  handler = "lambda_apigw.lambda_handler"
  runtime = "python2.7"
}

resource "aws_api_gateway_rest_api" "apigw" {
  name = "${var.apigw_name}_${random_string.gwsuffix.result}"
  endpoint_configuration {
    types = [
      "REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "apigw_resource" {
  parent_id = "${aws_api_gateway_rest_api.apigw.root_resource_id}"
  path_part = "{proxy+}"
  rest_api_id = "${aws_api_gateway_rest_api.apigw.id}"
}

resource "aws_api_gateway_authorizer" "apigw_author" {
  rest_api_id = "${aws_api_gateway_rest_api.apigw.id}"
  name = "authorizer2lambda_${random_string.gwsuffix.result}"
  type = "TOKEN"
  authorizer_uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${aws_lambda_function.lambda.function_name}/invocations"
  identity_validation_expression = ".{0,}"
  authorizer_result_ttl_in_seconds = 0
}

resource "aws_lambda_permission" "apigw2lambda" {
  function_name = "${aws_lambda_function.lambda.function_name}"
  statement_id = "${random_integer.state_id.result}"
  principal = "apigateway.amazonaws.com"
  action = "lambda:InvokeFunction"
  source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.apigw.id}/authorizers/${aws_api_gateway_authorizer.apigw_author.id}"
}

resource "aws_api_gateway_method" "apigw_method" {
  authorization = "CUSTOM"
  resource_id = "${aws_api_gateway_resource.apigw_resource.id}"
  rest_api_id = "${aws_api_gateway_rest_api.apigw.id}"
  authorizer_id = "${aws_api_gateway_authorizer.apigw_author.id}"
  http_method = "ANY"
  request_parameters {
    "method.request.path.proxy" = true
    "method.request.header.Authorization" = true
  }
}

resource "aws_api_gateway_integration" "apigw_method_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.apigw.id}"
  resource_id = "${aws_api_gateway_method.apigw_method.resource_id}"
  http_method = "ANY"
  integration_http_method = "ANY"
  #Below are works for normal external resource request.
  #type = "HTTP_PROXY"
  #uri = "http://ec2-52-81-54-160.cn-north-1.compute.amazonaws.com.cn:8126/{proxy}"

  #Below are works VPC internal NLB resource request. Change to your own VPC_LINK and internal ELB before you run this!!!
  type = "HTTP_PROXY"
  connection_type = "VPC_LINK"
  connection_id = "vp5b72"
  uri = "http://nlb-apigw-ef5b1846667bb776.elb.ap-southeast-1.amazonaws.com"

  request_parameters {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
  cache_key_parameters = [
    "method.request.header.Authorization"]
}

resource "aws_api_gateway_deployment" "apigw_deployment" {
  depends_on = [
    "aws_api_gateway_integration.apigw_method_integration"]
  rest_api_id = "${aws_api_gateway_rest_api.apigw.id}"
  stage_name = "useless"
}

resource "aws_api_gateway_stage" "stage" {
  stage_name = "dev"
  rest_api_id = "${aws_api_gateway_rest_api.apigw.id}"
  deployment_id = "${aws_api_gateway_deployment.apigw_deployment.id}"
}

resource "aws_api_gateway_method_settings" "setting" {
  rest_api_id = "${aws_api_gateway_rest_api.apigw.id}"
  stage_name = "${aws_api_gateway_stage.stage.stage_name}"
  method_path = "*/*"

  settings {
    metrics_enabled = true
    data_trace_enabled = true
    logging_level = "INFO"
  }
}



