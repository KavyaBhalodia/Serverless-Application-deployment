resource "aws_api_gateway_rest_api" "generic-api" {
  name = var.name
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "generic_resource" {
  count = length(var.path)

  path_part   = keys(var.path)[count.index]
  parent_id   = aws_api_gateway_rest_api.generic-api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.generic-api.id
}

resource "aws_api_gateway_method" "generic_method" {
  count = length(var.path)

  rest_api_id      = aws_api_gateway_rest_api.generic-api.id
  resource_id      = aws_api_gateway_resource.generic_resource[count.index].id
  http_method      = var.path[keys(var.path)[count.index]][0] 
  api_key_required = false
  authorization    = "NONE"
}


resource "aws_api_gateway_method_response" "generic_response" {
  depends_on = [ aws_api_gateway_method.generic_method ]
  count = length(var.path)
  rest_api_id = aws_api_gateway_rest_api.generic-api.id
  resource_id = aws_api_gateway_resource.generic_resource[count.index].id
  http_method = var.path[keys(var.path)[count.index]][0] 
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration" "generic_integration" {
  count = length(var.path)
  rest_api_id             = aws_api_gateway_rest_api.generic-api.id
  resource_id             = aws_api_gateway_resource.generic_resource[count.index].id
  http_method             = var.path[keys(var.path)[count.index]][0] 
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.invoke_arn
}


resource "aws_lambda_permission" "generic_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.generic-api.execution_arn}/*/*/*"
}


# -------------------
#  DEPLOYMENT
# -------------------

resource "aws_api_gateway_deployment" "generic_deployment" {
  rest_api_id = aws_api_gateway_rest_api.generic-api.id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.generic_resource[0].id,
      aws_api_gateway_resource.generic_resource[1].id,
      aws_api_gateway_resource.generic_resource[2].id,
      aws_api_gateway_method.generic_method[0].http_method,
      aws_api_gateway_method.generic_method[1].http_method,
      aws_api_gateway_method.generic_method[2].http_method,
      aws_api_gateway_integration.generic_integration[0].id,
      aws_api_gateway_integration.generic_integration[1].id,
      aws_api_gateway_integration.generic_integration[2].id,
    ]))
  }
  lifecycle {
    create_before_destroy = true
  }
}

# -------------------
#   STAGE
# -------------------

resource "aws_api_gateway_stage" "generic_Stage" {
  deployment_id = aws_api_gateway_deployment.generic_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.generic-api.id
  stage_name    = "Dev"
}


# -------------------
#   OPTIONS
# -------------------

resource "aws_api_gateway_method" "student_OPTIONS_method" {
  rest_api_id      = aws_api_gateway_rest_api.generic-api.id
  resource_id      = aws_api_gateway_resource.generic_resource[1].id
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = false
}

# OPTIONS method response.
resource "aws_api_gateway_method_response" "Student_CORS" {
  rest_api_id =  aws_api_gateway_rest_api.generic-api.id
  resource_id =  aws_api_gateway_resource.generic_resource[1].id
  http_method =  aws_api_gateway_method.student_OPTIONS_method.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# OPTIONS integration.
resource "aws_api_gateway_integration" "student_integration_OPTIONS" {
  rest_api_id          = aws_api_gateway_rest_api.generic-api.id
  resource_id          = aws_api_gateway_resource.generic_resource[1].id
  http_method          = "OPTIONS"
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"
  request_templates = {
    "application/json" : "{\"statusCode\": 200}"
  }
   depends_on = [
    aws_api_gateway_method.student_OPTIONS_method,
    aws_api_gateway_method_response.Student_CORS
  ]
}

# OPTIONS integration response.
resource "aws_api_gateway_integration_response" "student_integration_response_OPTIONS" {
  rest_api_id = aws_api_gateway_rest_api.generic-api.id
  resource_id = aws_api_gateway_resource.generic_resource[1].id
  http_method = aws_api_gateway_integration.student_integration_OPTIONS.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS,DELETE,PATCH'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [ aws_api_gateway_integration.student_integration_OPTIONS ]
}


# resource "aws_api_gateway_resource" "generic_resource" {
#   count = length(keys(var.path))

#   path_part   = keys(var.path)[count.index]
#   parent_id   = aws_api_gateway_rest_api.generic-api.root_resource_id
#   rest_api_id = aws_api_gateway_rest_api.generic-api.id
# }

# resource "aws_api_gateway_method" "generic_method" {
#   count = length(flatten(values(var.path)))

#   rest_api_id      = aws_api_gateway_rest_api.generic-api.id
#   resource_id      = aws_api_gateway_resource.generic_resource[count.index % length(aws_api_gateway_resource.generic_resource)].id
#   http_method      = element(flatten(values(var.path)), count.index)
#   api_key_required = false
#   authorization    = "NONE"
# }
