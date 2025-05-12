
resource "aws_iam_role" "cloudwatch_sns_publish" {
  name = "cloudwatch-sns-publish-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "events.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "cloudwatch_sns_policy" {
  name = "cloudwatch-sns-publish-policy"
  role = aws_iam_role.cloudwatch_sns_publish.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = "sns:Publish",
      Resource = var.sns_topic_arn
    }]
  })
}


resource "aws_cloudwatch_event_rule" "ec2_state_change_rule" {
  name = "ec2-state-change-to-sns"
  event_pattern = jsonencode({
    "source" : ["aws.ec2"],
    "detail-type" : ["EC2 Instance State-change Notification"],
    "detail" : {
      "state" : ["shutting-down", "terminated", "stopping", "stopped"]
    }
  })
}

resource "aws_cloudwatch_event_target" "send_to_sns" {
  rule     = aws_cloudwatch_event_rule.ec2_state_change_rule.name
  arn      = var.sns_topic_arn
  role_arn = aws_iam_role.cloudwatch_sns_publish.arn
}
