
resource "aws_iam_user" "user" {
  name = var.name
  tags = {
    created_by = var.created_by
  }
}

resource "aws_iam_user_group_membership" "user_membership" {
  user = aws_iam_user.user.name

  groups = var.groups
}


resource "aws_iam_access_key" "key" {
  user = aws_iam_user.user.name
}



resource "aws_secretsmanager_secret" "user_cred" {
  name = aws_iam_user.user.name

  recovery_window_in_days        = var.recovery_window_in_days
  force_overwrite_replica_secret = true

  tags = {
    created_by = var.created_by
  }
}

resource "aws_secretsmanager_secret_version" "user_cred_version" {
  secret_id = aws_secretsmanager_secret.user_cred.id
  secret_string = jsonencode({
    key_id = aws_iam_access_key.key.id
    secret = aws_iam_access_key.key.secret
  })
}
