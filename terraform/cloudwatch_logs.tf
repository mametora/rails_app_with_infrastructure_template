resource "aws_cloudwatch_log_group" "rake_task" {
  name              = "/${var.app_name}/${terraform.workspace}/rake_task"
  retention_in_days = var.ecs_log_retention_period[terraform.workspace]
}

resource "aws_cloudwatch_log_group" "migration" {
  name              = "/${var.app_name}/${terraform.workspace}/migration"
  retention_in_days = var.ecs_log_retention_period[terraform.workspace]
}

resource "aws_cloudwatch_log_group" "rails" {
  name              = "/${var.app_name}/${terraform.workspace}/rails"
  retention_in_days = var.ecs_log_retention_period[terraform.workspace]
}

resource "aws_cloudwatch_log_group" "sidekiq" {
  name              = "/${var.app_name}/${terraform.workspace}/sidekiq"
  retention_in_days = var.ecs_log_retention_period[terraform.workspace]
}

resource "aws_cloudwatch_log_group" "scheduled_task" {
  name              = "/${var.app_name}/${terraform.workspace}/scheduled_task"
  retention_in_days = var.ecs_log_retention_period[terraform.workspace]
}

resource "aws_cloudwatch_log_group" "debug_rails" {
  name              = "/${var.app_name}/${terraform.workspace}/debug_rails"
  retention_in_days = var.ecs_log_retention_period[terraform.workspace]
}

resource "aws_cloudwatch_log_group" "lambda_edge" {
  name              = "/${var.app_name}/${terraform.workspace}/lambda_edge"
  retention_in_days = var.lambda_edge_log_retention_period[terraform.workspace]
}
