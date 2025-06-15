resource "aws_iam_user" "user" {
  count = var.dedicated_user_data != null ? 1 : 0
  name  = var.dedicated_user_data.name
}

resource "aws_iam_access_key" "key" {
  count = var.dedicated_user_data != null ? 1 : 0
  user  = aws_iam_user.user[count.index].name
}

resource "aws_secretsmanager_secret" "user_cred" {
  count = var.dedicated_user_data != null ? 1 : 0
  name  = aws_iam_user.user[count.index].name

  recovery_window_in_days        = var.dedicated_user_data.ssm_recovery_window_in_days
  force_overwrite_replica_secret = true
}

resource "aws_secretsmanager_secret_version" "user_cred_version" {
  count     = var.dedicated_user_data != null ? 1 : 0
  secret_id = aws_secretsmanager_secret.user_cred[count.index].id

  secret_string = jsonencode({
    key_id = aws_iam_access_key.key[count.index].id
    secret = aws_iam_access_key.key[count.index].secret
  })
}
