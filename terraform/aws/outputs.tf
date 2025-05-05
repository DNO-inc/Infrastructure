
output "dbs_hosts" {
  value = {
    mysql         = module.mysql_rds.host
    redis         = module.redis_elasticache.host
    mongo         = module.mongo_docdb.host
    load_balancer = aws_lb.app.dns_name
  }
}

output "dbs_ports" {
  value = {
    mysql         = module.mysql_rds.port
    redis         = module.redis_elasticache.port
    mongo         = module.mongo_docdb.port
    load_balancer = aws_lb_listener.http.port
  }
}

