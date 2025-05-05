
variable "elasticache_cluster_id" {
  type = string
}

variable "elasticache_engine" {
  type = string
}

variable "elasticache_engine_version" {
  type = string
}

variable "elasticache_node_type" {
  type = string
}

variable "elasticache_node_count" {
  type    = number
  default = 1
}

variable "parameter_group_name" {
  type = string
}

variable "elasticache_port" {
  type    = number
  default = 6379
}

variable "elasticache_subnets" {
  type = list(string)
}

variable "elasticache_security_groups" {
  type = set(string)
}

variable "elasticache_subnet_group_name" {
  type = string
}
