
resource "aws_ssm_parameter" "email_list" {
  name  = var.ssm_parameter_name_for_email_list
  type  = "StringList"
  value = join(",", var.email_list)
}
