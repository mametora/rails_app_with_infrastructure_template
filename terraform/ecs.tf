resource "aws_ecs_cluster" "default" {
  name = "${var.app_name}-${terraform.workspace}"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_service" "rails" {
  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }

  name                               = "${var.app_name}-${terraform.workspace}-rails"
  cluster                            = aws_ecs_cluster.default.arn
  task_definition                    = aws_ecs_task_definition.rails.arn
  desired_count                      = var.rails_task_desired_count[terraform.workspace]
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  platform_version                   = "1.4.0"

  network_configuration {
    assign_public_ip = false
    security_groups = [
      module.web_sg.this_security_group_id,
      module.rails_sg.this_security_group_id
    ]
    subnets = [
      aws_subnet.private_a.id,
      aws_subnet.private_c.id,
      aws_subnet.private_d.id
    ]
  }

  depends_on                        = [aws_alb.default]
  health_check_grace_period_seconds = 60
  load_balancer {
    target_group_arn = aws_lb_target_group.rails.arn
    container_name   = "${var.app_name}-${terraform.workspace}-rails"
    container_port   = 80
  }
}

resource "aws_ecs_service" "sidekiq" {
  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }

  name                               = "${var.app_name}-${terraform.workspace}-sidekiq"
  cluster                            = aws_ecs_cluster.default.arn
  task_definition                    = aws_ecs_task_definition.sidekiq.arn
  desired_count                      = var.sidekiq_task_desired_count[terraform.workspace]
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  platform_version                   = "1.4.0"

  network_configuration {
    assign_public_ip = false
    security_groups = [module.rails_sg.this_security_group_id]

    subnets = [
      aws_subnet.private_a.id,
      aws_subnet.private_c.id,
      aws_subnet.private_d.id
    ]
  }
}
