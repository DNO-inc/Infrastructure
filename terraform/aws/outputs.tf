
output "dbs_hosts" {
  value = {
    mysql = module.mysql_rds.host
    redis = module.redis_elasticache.host
    mongo = module.mongo_docdb.host
  }
}

output "dbs_ports" {
  value = {
    mysql = module.mysql_rds.port
    redis = module.redis_elasticache.port
    mongo = module.mongo_docdb.port
  }
}
