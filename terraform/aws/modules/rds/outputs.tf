
output "host" {
  value = aws_db_instance.db_instance.address
}

output "port" {
  value = aws_db_instance.db_instance.port
}
