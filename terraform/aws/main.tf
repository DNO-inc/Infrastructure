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

  db_subnets = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]
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

  docdb_subnets = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]
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

  elasticache_subnets = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]
  elasticache_security_groups = [
    aws_security_group.redis.id
  ]
}


module "burrito_ecs" {
  source = "./modules/ecs"

  container_name = "burrito"

  task_role_arn      = aws_iam_role.ecs_task_execution_role.arn
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  ecs_cluster_id = aws_ecs_cluster.main_cluster.id

  ecs_service_name = "burrito-service"

  ecs_task_family                = "burrito"
  ecs_task_container_definitions = "./ecs/burrito-definition"
  ecs_task_cpu                   = "1024"
  ecs_task_memory                = "2048"

  ecs_service_security_groups = [
    aws_security_group.burrito.id,
    aws_security_group.egress.id
  ]
  ecs_service_subnets = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]

  env_file_path = var.env_file_template
  env_map = {
    mysql_host     = module.mysql_rds.host
    mysql_port     = module.mysql_rds.port
    mysql_user     = var.rds_user
    mysql_password = var.rds_password

    redis_host     = module.redis_elasticache.host
    redis_port     = module.redis_elasticache.port
    redis_user     = var.redis_user
    redis_password = var.redis_password

    mongo_host     = module.mongo_docdb.host
    mongo_port     = module.mongo_docdb.port
    mongo_user     = var.mongo_user
    mongo_password = var.mongo_password
  }

  lb_target_arn = aws_lb_target_group.ecs.arn

  depends_on = [
    module.mongo_docdb,
    module.mysql_rds,
    module.redis_elasticache,
    aws_lb_listener.http
  ]
}


#module "static_apps" {
#  source = "./modules/s3_sites"
#
#  bucket_name = "super-mega-static-apps"
#
#  allowed_headers = ["*"]
#  allowed_methods = ["GET"]
#  allowed_origins = ["*"]
#  expose_headers  = ["ETag"]
#}
