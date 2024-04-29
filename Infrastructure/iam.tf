
resource "aws_iam_role" "Harshvardhan_Lambda_Role" {
  name = "Harshvardhan_Lambda_Role"

  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = {
    Name        = "Harshvardhan_Student_data"

  }
}

resource "aws_iam_role_policy_attachment" "Harshvardhan_Role_Attachment" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
    "arn:aws:iam::aws:policy/AWSLambda_FullAccess",
    "arn:aws:iam::aws:policy/CloudWatchFullAccess"
  ])

  role       = aws_iam_role.Harshvardhan_Lambda_Role.name
  policy_arn = each.value
}



