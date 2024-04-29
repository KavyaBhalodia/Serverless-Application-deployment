# Terraform Version Specification.
terraform {
  required_providers {
    aws = {
      version = "~> 5.35.0"
    }
  }

  required_version = "~> 1.7"
}

# Intialized Backend here.
terraform {
  backend "s3" {
    bucket = "kavya-serverless-app-deployment-bucket"
    key    = "serverless/terraform.tfstate"
    region = "us-west-2"
  }
} 

# AWS Provider 
provider "aws" {
  # profile = var.profile
  region  = "us-west-2"
}

module "api_GW" {
  source = "./modules/api-gw"
  name   = "Student_api"
  path = {
    "health"   = ["GET"],
    "students" = ["GET"]
    "student"  = ["ANY"]
  }
  invoke_arn    = module.lambda.invoke_arn
  function_name = module.lambda.function_name
}

module "dynamodb" {
  source         = "./modules/dynamodb"
  name           = "Student_Data"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "studentId"
  attribute_name = "studentId"
  attribute_type = "S"

}


module "lambda" {
  source  = "./modules/lambda"
  name    = "lambda"
  role    = aws_iam_role.Lambda_Role.arn
  handler = "lambda_function.lambda_handler"
  file    = data.archive_file.lambda_zip.output_path
  hash    = data.archive_file.lambda_zip.output_base64sha256
  runtime = "python3.12"
}

resource "local_file" "env_file" {
  content  = "REACT_APP_API_INVOKE_URL=${module.api_GW.api_url}"
  filename = "../frontend/.env"
}