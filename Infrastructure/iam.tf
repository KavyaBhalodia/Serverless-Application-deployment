
resource "aws_iam_role" "Lambda_Role" {
  name = "Lambda_Role"

  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = {
    Name        = "Student_data"

  }
}

resource "aws_iam_role_policy_attachment" "Role_Attachment" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
    "arn:aws:iam::aws:policy/AWSLambda_FullAccess",
    "arn:aws:iam::aws:policy/CloudWatchFullAccess"
  ])

  role       = aws_iam_role.Lambda_Role.name
  policy_arn = each.value
}



