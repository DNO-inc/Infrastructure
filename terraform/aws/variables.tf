
variable "aws_region" {
  type    = string
  default = "eu-west-3"
}

variable "env_file_template" {
  type = string
}

variable "rds_user" {
  type = string
}

variable "rds_password" {
  type = string
}

variable "mongo_user" {
  type = string
}

variable "mongo_password" {
  type = string
}

variable "redis_user" {
  type    = string
  default = ""
}
variable "redis_password" {
  type    = string
  default = ""
}
