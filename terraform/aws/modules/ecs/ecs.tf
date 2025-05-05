
locals {
  file_content = var.env_file_path != "" ? templatefile(var.env_file_path, var.env_map) : ""
  lines        = split("\n", trimspace(local.file_content))

  environment_vars = var.env_file_path != "" ? [
    for line in local.lines : {
      name  = element(split("=", line), 0)
      value = element(split("=", line), 1)
    }
    if length(trimspace(line)) > 0
  ] : []
}


resource "aws_ecs_service" "ecs_service" {
  name                               = var.ecs_service_name
  cluster                            = var.ecs_cluster_id
  task_definition                    = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 60
  deployment_maximum_percent         = 100
  launch_type                        = "FARGATE"

  network_configuration {
    security_groups  = var.ecs_service_security_groups
    subnets          = var.ecs_service_subnets
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.lb_target_arn
    container_name   = var.container_name
    container_port   = 8080
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family = var.ecs_task_family
  container_definitions = templatefile(
    var.ecs_task_container_definitions,
    {
      ecs_task_cpu     = var.ecs_task_cpu
      ecs_task_memory  = var.ecs_task_memory
      environment_vars = jsonencode(local.environment_vars)
      container_name   = var.container_name
    }
  )

  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = var.ecs_task_cpu
  memory = var.ecs_task_memory

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }
}
