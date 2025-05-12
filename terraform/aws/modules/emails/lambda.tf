
locals {
  lambda_zip_artifact_path = "/tmp/${var.function_filename}.zip"
}


data "aws_region" "current" {}
data "aws_caller_identity" "current" {}



data "aws_iam_policy_document" "AWSLambdaTrustPolicy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_ssm_access" {
  statement {
    actions = ["ssm:GetParameter"]
    effect  = "Allow"
    resources = [
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${var.ssm_parameter_name_for_email_list}"
    ]
  }
}

data "aws_iam_policy_document" "lambda_ses_access" {
  statement {
    actions = ["ses:SendEmail"]
    effect  = "Allow"
    resources = [
      "*"
    ]
  }
}



resource "aws_iam_role" "terraform_function_role" {
  name               = "terraform-email-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.AWSLambdaTrustPolicy.json
}


resource "aws_iam_policy" "lambda_ssm_policy" {
  name   = "lambda-ssm-get-param"
  policy = data.aws_iam_policy_document.lambda_ssm_access.json
}

resource "aws_iam_policy" "lambda_ses_policy" {
  name   = "lambda-ses-send"
  policy = data.aws_iam_policy_document.lambda_ses_access.json
}


resource "aws_iam_role_policy_attachment" "terraform_lambda_policy" {
  role       = aws_iam_role.terraform_function_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_ssm_attach" {
  role       = aws_iam_role.terraform_function_role.name
  policy_arn = aws_iam_policy.lambda_ssm_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_ses_attach" {
  role       = aws_iam_role.terraform_function_role.name
  policy_arn = aws_iam_policy.lambda_ses_policy.arn
}



data "archive_file" "python_lambda_package" {
  type        = "zip"
  source_file = var.function_filename
  output_path = local.lambda_zip_artifact_path
}

resource "aws_lambda_function" "email_processor_func" {
  function_name = var.function_name
  role          = aws_iam_role.terraform_function_role.arn

  filename         = local.lambda_zip_artifact_path
  source_code_hash = data.archive_file.python_lambda_package.output_base64sha256

  runtime = "python3.9"
  handler = "${split(".", basename(var.function_filename))[0]}.lambda_handler"

  environment {
    variables = {
      EMAIL_LIST_SSM_PARAMETER = var.ssm_parameter_name_for_email_list
      SOURCE_EMAIL_ADDRESS     = var.email_source_address
    }
  }
}

resource "aws_sns_topic_subscription" "email_target" {
  topic_arn = var.sns_topic_arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.email_processor_func.arn
}

resource "aws_lambda_permission" "allow_invocation_from_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.email_processor_func.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.sns_topic_arn
}
