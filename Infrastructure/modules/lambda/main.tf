resource "aws_lambda_function" "Harshvardhan_Lambda_backend" {
  function_name    = var.name
  role             = var.role
  handler          = var.handler
  filename         = var.file
  source_code_hash = var.hash
  runtime          = var.runtime
}