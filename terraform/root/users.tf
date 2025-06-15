
module "terraform_user" {
  source = "./modules/iam_users"

  name = "terraform-test-admin"

  groups = [
    aws_iam_group.dbs_admins.name,
    aws_iam_group.eks_admins.name,
    aws_iam_group.vpc_admins.name
  ]

  recovery_window_in_days = 7

  created_by = local.created_by
}
