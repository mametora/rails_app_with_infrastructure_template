data "aws_iam_policy" "ecs_task_execution_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_execution" {
  source_json = data.aws_iam_policy.ecs_task_execution_role_policy.policy

  statement {
    effect    = "Allow"
    actions   = [
      "ssm:GetParameters",
      "kms:Decrypt"
    ]
    resources = ["*"]
  }
}

module "ecs_execution_role" {
  source      = "./module/iam"
  name        = "${var.app_name}-${terraform.workspace}-ecs-execution"
  identifiers = ["ecs-tasks.amazonaws.com"]
  policy      = data.aws_iam_policy_document.ecs_execution.json
}

data "aws_iam_policy_document" "ecs_task" {
  statement {
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = [
      "ses:SendRawEmail",
      "ses:SendEmail"
    ]
    resources = ["*"]
  }
}

module "ecs_task_role" {
  source      = "./module/iam"
  name        = "${var.app_name}-${terraform.workspace}-ecs-task"
  identifiers = ["ecs-tasks.amazonaws.com"]
  policy      = data.aws_iam_policy_document.ecs_task.json
}

# rails
resource "aws_ecs_task_definition" "rails" {
  family                   = "${var.app_name}-${terraform.workspace}-rails"
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = data.template_file.definition_for_rails.rendered
  execution_role_arn       = module.ecs_execution_role.iam_role_arn
  task_role_arn            = module.ecs_task_role.iam_role_arn
}

data "template_file" "definition_for_rails" {
  template = file("./container_definitions/rails.json")

  vars = {
    aws_account_id = var.aws_account_id
    app            = var.app_name
    workspace      = terraform.workspace
    region         = var.region
    log_group      = aws_cloudwatch_log_group.rails.name
  }
}

# sidekiq
resource "aws_ecs_task_definition" "sidekiq" {
  family                   = "${var.app_name}-${terraform.workspace}-sidekiq"
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = data.template_file.definition_for_sidekiq.rendered
  execution_role_arn       = module.ecs_execution_role.iam_role_arn
  task_role_arn            = module.ecs_task_role.iam_role_arn
  tags                     = {
    Name    = "${var.app_name}-${terraform.workspace}-sidekiq"
    Env     = terraform.workspace
    Product = var.app_name
  }
}

data "template_file" "definition_for_sidekiq" {
  template = file("./container_definitions/sidekiq.json")

  vars = {
    region         = var.region
    aws_account_id = var.aws_account_id
    app            = var.app_name
    workspace      = terraform.workspace
    log_group      = aws_cloudwatch_log_group.sidekiq.name
  }
}

# migration
data "template_file" "service_container_definition_migration" {
  template = file("./container_definitions/migration.json")

  vars = {
    region         = var.region
    aws_account_id = var.aws_account_id
    app            = var.app_name
    workspace      = terraform.workspace
    log_group      = aws_cloudwatch_log_group.migration.name
  }
}

resource "aws_ecs_task_definition" "migration" {
  family                   = "${var.app_name}-${terraform.workspace}-migration"
  container_definitions    = data.template_file.service_container_definition_migration.rendered
  execution_role_arn       = module.ecs_execution_role.iam_role_arn
  task_role_arn            = module.ecs_task_role.iam_role_arn
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
}
