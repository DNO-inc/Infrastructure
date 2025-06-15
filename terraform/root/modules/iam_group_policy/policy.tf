
resource "aws_iam_policy" "policy" {
  name        = var.name
  description = var.description
  policy      = file(var.policy_filename)
  tags = {
    created_by = var.created_by
  }
}

resource "aws_iam_group_policy_attachment" "attachment" {
  group      = var.group_name
  policy_arn = aws_iam_policy.policy.arn
}
