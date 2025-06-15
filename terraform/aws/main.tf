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


module "mysql_rds" {
  source = "./modules/rds"

  allocated_storage = 10

  db_name           = "burrito"
  db_engine         = "mysql"
  db_engine_version = "8.4.4"
  db_instance_class = "db.t4g.micro"

  db_username = var.rds_user
  db_password = var.rds_password

  db_subnets = values(aws_subnet.private)[*].id
  db_security_groups = [
    aws_security_group.mysql.id
  ]

  db_subnet_group_name = "apps-subnet-group"
}


module "mongo_docdb" {
  source = "./modules/document_db"

  docdb_subnet_group_name = "apps-docdb-subnet-group"

  docdb_cluster_identifier = "apps-docdb-cluster"
  docdb_engine             = "docdb"
  docdb_engine_version     = "4.0.0"

  docdb_cluster_instance_identifier = "apps-docdb-cluster-instance"
  docdb_cluster_instance_class      = "db.t3.medium"

  docdb_username = var.mongo_user
  docdb_password = var.mongo_password

  docdb_subnets = values(aws_subnet.private)[*].id
  docdb_security_groups = [
    aws_security_group.mongo.id
  ]
}


module "redis_elasticache" {
  source = "./modules/elastic_cache"

  elasticache_cluster_id     = "apps-redis-cluster"
  elasticache_engine         = "redis"
  elasticache_engine_version = "4.0.10"
  elasticache_node_type      = "cache.t3.micro"
  elasticache_node_count     = 1

  parameter_group_name = "default.redis4.0"

  elasticache_subnet_group_name = "apps-redis-subnet-group"

  elasticache_subnets = values(aws_subnet.private)[*].id
  elasticache_security_groups = [
    aws_security_group.redis.id
  ]
}


module "nat_instance" {
  source = "./modules/nat_instance"

  for_each = aws_subnet.public

  subnet_id = each.value.id

  instance_type = "t3.micro"

  security_groups = [
    aws_security_group.egress.id,
    aws_security_group.nat_ingress.id
  ]

  user_data = file("${path.module}/etc/nat_instance_userdata")
}

module "eks" {
  source = "./modules/eks"

  vpc_id = aws_vpc.main.id

  cluster_name = "my-eks-cluster"

  subnet_ids = values(aws_subnet.private)[*].id

  additional_node_sg = [
    aws_security_group.burrito.id
  ]
}


module "sns_email" {
  source = "./modules/emails"

  sns_topic_arn = aws_sns_topic.critical.arn

  ssm_parameter_name_for_email_list = var.ssm_parameter_name_for_email_list
  email_list                        = var.sns_subscribers_email_list

  email_source_address = var.email_source_address

  function_name     = "email-notifications"
  function_filename = "${path.module}/etc/email_processor_func.py"
}


module "s3_burrito_api_files" {
  source = "./modules/s3"

  bucket_name = "burrito-api-files"

  dedicated_user_data = {
    name                        = "s3-user-burrito-api-files"
    ssm_recovery_window_in_days = 30
  }
}


module "s3_tres_static" {
  source = "./modules/s3"

  bucket_name = "tres-static"

  cors_rules = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET"]
      allowed_origins = ["*"]
      expose_headers  = ["ETag"]
    }
  ]

  site_config = {
    index_document = "index.html"
    error_document = "index.html"
  }

  acl_config = {
    block_public_acls       = false
    block_public_policy     = false
    ignore_public_acls      = false
    restrict_public_buckets = false
  }

  dedicated_user_data = {
    name                        = "s3-user-tres-static"
    ssm_recovery_window_in_days = 30
  }
}
