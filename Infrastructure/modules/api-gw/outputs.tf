output "api_url" {
  value = aws_api_gateway_deployment.generic_deployment.invoke_url
}