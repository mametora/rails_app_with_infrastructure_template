locals {
  security_group_ids = [module.rails_sg.this_security_group_id]
  subnet_ids         = [
    aws_subnet.private_a.id,
    aws_subnet.private_c.id,
    aws_subnet.private_d.id
  ]
}

module "sitemap_generate_scheduled_task" {
  source         = "./module/scheduled_task"
  aws_account_id = var.aws_account_id
  app_name       = var.app_name
  workspace      = terraform.workspace

  target_cluster_arn = aws_ecs_cluster.default.arn
  log_group          = aws_cloudwatch_log_group.scheduled_task.name
  execution_role_arn = module.ecs_execution_role.iam_role_arn
  task_role_arn      = module.ecs_task_role.iam_role_arn
  subnet_ids         = local.subnet_ids
  security_group_ids = local.security_group_ids
  region             = var.region

  task                = terraform.workspace == "prod" ? "sitemap:refresh" : "sitemap:refresh:no_ping"
  family              = "${var.app_name}-${terraform.workspace}-sitemap-generate"
  schedule_expression = "cron(0 20 * * ? *)"
}
