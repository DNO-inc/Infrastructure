
variable "ecs_cluster_id" {
  type = string
}

variable "ecs_service_name" {
  type = string
}

variable "ecs_task_family" {
  type = string
}

variable "ecs_task_container_definitions" {
  type        = string
  description = "Path to the with container definitions for the task"
}

variable "ecs_task_cpu" {
  type = string
}

variable "ecs_task_memory" {
  type = string
}

variable "ecs_service_security_groups" {
  type = list(string)
}

variable "ecs_service_subnets" {
  type = list(string)
}

variable "env_file_path" {
  type    = string
  default = ""
}

variable "env_map" {
  type    = map(any)
  default = {}
}

variable "lb_target_arn" {
  type = string
}

variable "container_name" {
  type = string
}

variable "execution_role_arn" {
  type = string
}

variable "task_role_arn" {
  type = string
}
