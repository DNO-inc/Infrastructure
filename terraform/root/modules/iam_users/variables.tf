
variable "name" {
  type = string
}

variable "groups" {
  type = list(string)
}

variable "recovery_window_in_days" {
  type    = number
  default = 30
}

variable "created_by" {
  type = string
}
