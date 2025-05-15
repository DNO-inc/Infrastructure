
variable "sns_topic_arn" {
  type = string
}

variable "ssm_parameter_name_for_email_list" {
  type = string
}

variable "email_list" {
  type = list(string)
}

variable "function_name" {
  type = string
}

variable "function_filename" {
  type = string
}

variable "email_source_address" {
  type = string
}

variable "logs_retention_days" {
  type    = number
  default = 3
}
