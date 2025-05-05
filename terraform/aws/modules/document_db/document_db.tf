
resource "aws_db_subnet_group" "docdb_subnet_group" {
  name       = var.docdb_subnet_group_name
  subnet_ids = var.docdb_subnets
}

resource "aws_docdb_cluster" "docdb_cluster" {
  cluster_identifier  = var.docdb_cluster_identifier
  engine              = var.docdb_engine
  engine_version      = var.docdb_engine_version
  master_username     = var.docdb_username
  master_password     = var.docdb_password
  port                = var.docdb_port
  skip_final_snapshot = var.skip_final_snapshot

  vpc_security_group_ids = var.docdb_security_groups

  db_subnet_group_name = aws_db_subnet_group.docdb_subnet_group.name
}

resource "aws_docdb_cluster_instance" "mongo_cluster_instance" {
  identifier         = var.docdb_cluster_instance_identifier
  cluster_identifier = aws_docdb_cluster.docdb_cluster.id
  instance_class     = var.docdb_cluster_instance_class
}
