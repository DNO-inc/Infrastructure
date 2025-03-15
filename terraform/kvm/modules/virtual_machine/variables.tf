
variable "vm_name" {
  type = string
}
variable "memory" {
  type = string
}
variable "vcpu" {
  type = number
}
variable "cloudinit_template_path" {
  type = string
}
variable "os_image_path" {
  type = string
}
variable "admin_user_public_key" {
  type = string
}
