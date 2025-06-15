
variable "bucket_name" {
  type = string
}

variable "cors_rules" {
  type = list(object({
    allowed_headers = list(string)
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = list(string)
    max_age_seconds = optional(number)
  }))
  default = null
}

variable "site_config" {
  type = object({
    index_document = string
    error_document = optional(string)
  })
  default = null
}

variable "acl_config" {
  type = object({
    block_public_acls       = bool
    block_public_policy     = bool
    ignore_public_acls      = bool
    restrict_public_buckets = bool
  })
  default = null
}

variable "dedicated_user_data" {
  type = object({
    name                        = string
    ssm_recovery_window_in_days = number
  })
  default = null
}
