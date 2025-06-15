terraform {
  backend "s3" {
    bucket  = ""
    key     = ""
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}



resource "aws_iam_policy" "global_deny_policy" {
  name = "global-deny"
  policy = templatefile(
    "./policies/groups/explicit-denies.json",
    {
      account_id = data.aws_caller_identity.current.account_id,
      created_by = local.created_by
    }
  )

  tags = {
    created_by = local.created_by
  }
}

resource "aws_iam_group_policy_attachment" "dbs_denies" {
  group      = aws_iam_group.dbs_admins.name
  policy_arn = aws_iam_policy.global_deny_policy.arn
}

resource "aws_iam_group_policy_attachment" "eks_denies" {
  group      = aws_iam_group.eks_admins.name
  policy_arn = aws_iam_policy.global_deny_policy.arn
}

resource "aws_iam_group_policy_attachment" "vpc_denies" {
  group      = aws_iam_group.vpc_admins.name
  policy_arn = aws_iam_policy.global_deny_policy.arn
}
