
variable "subnet_id" {
  type = string
}

variable "security_groups" {
  type = list(string)
}

variable "user_data_replace_on_change" {
  type    = bool
  default = true
}

variable "user_data" {
  type = string
}

variable "instance_type" {
  type = string
}
