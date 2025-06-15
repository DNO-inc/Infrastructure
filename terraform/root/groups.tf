
#########################################
#               EKS-ADMINS
#########################################

resource "aws_iam_group" "eks_admins" {
  name = "EKS-ADMINS"
}


module "eks_modification_policy" {
  source = "./modules/iam_group_policy"

  name = "eks-modification"

  group_name = aws_iam_group.eks_admins.name

  policy_filename = "./policies/groups/eks-modification.json"

  created_by = local.created_by
}

module "ec2_modification_policy" {
  source = "./modules/iam_group_policy"

  name = "ec2-modification"

  group_name = aws_iam_group.eks_admins.name

  policy_filename = "./policies/groups/ec2-modification.json"

  created_by = local.created_by
}

#########################################
#               VPC-ADMINS
#########################################

resource "aws_iam_group" "vpc_admins" {
  name = "VPC-ADMINS"
}


module "vpc_modification_policy" {
  source = "./modules/iam_group_policy"

  name = "vpc-modification"

  group_name = aws_iam_group.vpc_admins.name

  policy_filename = "./policies/groups/vpc-modification.json"

  created_by = local.created_by
}

module "s3_modification_policy" {
  source = "./modules/iam_group_policy"

  name = "s3-modification"

  group_name = aws_iam_group.vpc_admins.name

  policy_filename = "./policies/groups/s3-modification.json"

  created_by = local.created_by
}


#########################################
#               DBS-ADMINS
#########################################

resource "aws_iam_group" "dbs_admins" {
  name = "DBS-ADMINS"
}


module "dbs_modification_policy" {
  source = "./modules/iam_group_policy"

  name = "dbs-modification"

  group_name = aws_iam_group.dbs_admins.name

  policy_filename = "./policies/groups/dbs-modification.json"

  created_by = local.created_by
}
