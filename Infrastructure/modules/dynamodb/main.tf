resource "aws_dynamodb_table" "generic-dynamodb" {
  name           = var.name
  billing_mode   = "PROVISIONED"
  read_capacity  = var.read_capacity
  write_capacity = var.write_capacity
  hash_key       = var.hash_key

  attribute {
    name = var.attribute_name
    type = var.attribute_type
  }

  tags = {
    Name = var.name
  }
}