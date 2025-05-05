
output "host" {
  value = aws_elasticache_cluster.elasticache_cluster.cache_nodes[0].address
}

output "port" {
  value = aws_elasticache_cluster.elasticache_cluster.cache_nodes[0].port
}
