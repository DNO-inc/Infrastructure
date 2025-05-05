
output "host" {
  value = split(":", aws_docdb_cluster.docdb_cluster.endpoint)[0]
}

output "port" {
  value = aws_docdb_cluster.docdb_cluster.port
}
