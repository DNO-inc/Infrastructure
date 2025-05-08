
resource "aws_sns_topic" "email_topic" {
  name = var.name
}

resource "aws_sns_topic_subscription" "email_target" {
  count     = length(var.email_list)
  topic_arn = aws_sns_topic.email_topic.arn
  protocol  = "email"
  endpoint  = var.email_list[count.index]
}
