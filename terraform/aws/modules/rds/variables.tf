variable "db_subnet_group_name" {
  type = string
}

variable "db_subnets" {
  type = list(string)
}

variable "db_security_groups" {
  type = list(string)
}

variable "allocated_storage" {
  type    = number
  default = 10
}

variable "db_name" {
  type = string
}

variable "db_engine" {
  type = string
}

variable "db_engine_version" {
  type = string
}

variable "db_instance_class" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}

variable "skip_final_snapshot" {
  type    = bool
  default = true
}
