
variable "vpc_id" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "additional_node_sg" {
  type = list(string)
}
