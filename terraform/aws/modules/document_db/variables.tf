
variable "docdb_subnet_group_name" {
  type = string
}

variable "docdb_cluster_identifier" {
  type = string
}

variable "docdb_engine" {
  type = string
}

variable "docdb_engine_version" {
  type = string
}


variable "docdb_username" {
  type = string
}

variable "docdb_password" {
  type = string
}

variable "docdb_port" {
  type    = number
  default = 27017
}

variable "skip_final_snapshot" {
  type    = bool
  default = true
}

variable "docdb_cluster_instance_identifier" {
  type = string
}

variable "docdb_cluster_instance_class" {
  type = string
}

variable "docdb_subnets" {
  type = list(string)
}

variable "docdb_security_groups" {
  type = list(string)
}
