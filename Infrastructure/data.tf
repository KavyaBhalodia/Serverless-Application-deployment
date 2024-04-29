data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "../backend"
  output_path = "lambda_function.zip"
}


data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
