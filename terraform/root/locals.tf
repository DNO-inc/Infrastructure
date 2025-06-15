
data "aws_caller_identity" "current" {}

locals {
  created_by = data.aws_caller_identity.current.arn
}
