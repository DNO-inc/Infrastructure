
resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name = var.elasticache_subnet_group_name

  subnet_ids = var.elasticache_subnets
}

resource "aws_elasticache_cluster" "elasticache_cluster" {
  cluster_id           = var.elasticache_cluster_id
  engine               = var.elasticache_engine
  engine_version       = var.elasticache_engine_version
  node_type            = var.elasticache_node_type
  num_cache_nodes      = var.elasticache_node_count
  parameter_group_name = var.parameter_group_name
  port                 = var.elasticache_port

  security_group_ids = var.elasticache_security_groups

  subnet_group_name = aws_elasticache_subnet_group.redis_subnet_group.name
}
