variable "aws_account_id" {}
variable "app_name" {}
variable "workspace" {}
variable "region" {}
variable "log_group" {}
variable "task" {}
variable "family" {}
variable "execution_role_arn" {}
variable "schedule_expression" {}
variable "target_cluster_arn" {}
variable "task_role_arn" {}
variable "subnet_ids" {}
variable "security_group_ids" {}

data "template_file" "default" {
  template = file("container_definitions/batch.json")

  vars = {
    aws_account_id = var.aws_account_id
    app            = var.app_name
    workspace      = var.workspace
    region         = var.region
    log_group      = var.log_group
    task           = var.task
  }
}

resource "aws_ecs_task_definition" "default" {
  family                   = var.family
  container_definitions    = data.template_file.default.rendered
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
}

output "task_arn" {
  value = aws_ecs_task_definition.default.arn
}

module "scheduled_task" {
  source              = "baikonur-oss/fargate-scheduled-task/aws"
  name                = var.family
  schedule_expression = var.schedule_expression
  is_enabled          = true
  target_cluster_arn  = var.target_cluster_arn
  task_definition_arn = aws_ecs_task_definition.default.arn
  task_role_arn       = var.task_role_arn
  execution_role_arn  = var.execution_role_arn
  task_count          = 1
  subnet_ids          = var.subnet_ids
  security_group_ids  = var.security_group_ids
}
