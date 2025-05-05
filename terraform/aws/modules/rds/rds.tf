
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = var.db_subnet_group_name
  subnet_ids = var.db_subnets
}

resource "aws_db_instance" "db_instance" {
  allocated_storage = var.allocated_storage
  db_name           = var.db_name
  engine            = var.db_engine
  engine_version    = var.db_engine_version
  instance_class    = var.db_instance_class
  username          = var.db_username
  password          = var.db_password

  publicly_accessible = false

  skip_final_snapshot = var.skip_final_snapshot

  vpc_security_group_ids = var.db_security_groups

  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
}
