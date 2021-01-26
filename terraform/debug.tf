data "aws_iam_policy_document" "ecs_instance" {
  statement {
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = [
      "ecs:CreateCluster",
      "ecs:DeregisterContainerInstance",
      "ecs:DiscoverPollEndpoint",
      "ecs:Poll",
      "ecs:RegisterContainerInstance",
      "ecs:StartTelemetrySession",
      "ecs:UpdateContainerInstancesState",
      "ecs:Submit*",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

module "ecs_instance_role" {
  source      = "./module/iam"
  name        = "${var.app_name}-${terraform.workspace}-debug"
  identifiers = ["ec2.amazonaws.com"]
  policy      = data.aws_iam_policy_document.ecs_instance.json
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_attach_ssm" {
  role       = module.ecs_instance_role.iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_instance_profile" "ecs_instance" {
  name = "${var.app_name}-${terraform.workspace}-ecs-instance"
  role = module.ecs_instance_role.iam_role_name
}

resource "aws_security_group" "ecs_instance" {
  name        = "${var.app_name}-${terraform.workspace}-ecs-instance"
  description = "ecs ec2 instance sg"
  vpc_id      = aws_vpc.default.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "template_file" "user_data_for_ssm_agent" {
  template = file("user_data/ssm_agent.tpl")

  vars = {
    cluster_name = aws_ecs_cluster.default.name
  }
}

data "aws_ami" "amazon_linux_ecs_optimized" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "block-device-mapping.volume-type"
    values = ["gp2"]
  }
}

data "template_file" "service_container_definition_for_debug" {
  template = file("./container_definitions/debug.json")

  vars = {
    aws_account_id = var.aws_account_id
    app            = var.app_name
    workspace      = terraform.workspace
    region         = var.region
    log_group      = aws_cloudwatch_log_group.debug_rails.name
  }
}

resource "aws_ecs_task_definition" "rails_debug" {
  family                = "${var.app_name}-${terraform.workspace}-rails-debug"
  container_definitions = data.template_file.service_container_definition_for_debug.rendered
  network_mode          = "bridge"
  execution_role_arn    = module.ecs_execution_role.iam_role_arn
  task_role_arn         = module.ecs_task_role.iam_role_arn
}

# NOTE: debug用EC2必要な時にコメントアウトをはずして起動する
#resource "aws_ecs_service" "debug" {
#  name                               = "${var.app_name}-${terraform.workspace}-rails-debug"
#  cluster                            = aws_ecs_cluster.default.id
#  task_definition                    = aws_ecs_task_definition.rails_debug.arn
#  deployment_minimum_healthy_percent = 0
#  desired_count                      = 1
#  launch_type                        = "EC2"
#}
#
#resource "aws_spot_instance_request" "ecs_ec2_spot" {
#  lifecycle {
#    ignore_changes = [ami]
#  }
#
#  availability_zone    = "ap-northeast-1a"
#  ami                  = data.aws_ami.amazon_linux_ecs_optimized.id
#  instance_type        = var.debug_ecs_instance_type
#  monitoring           = true
#  iam_instance_profile = aws_iam_instance_profile.ecs_instance.name
#  subnet_id            = aws_subnet.private_a.id
#  user_data            = data.template_file.user_data_for_ssm_agent.rendered
#
#  vpc_security_group_ids = [module.rails_sg.this_security_group_id]
#
#  credit_specification {
#    cpu_credits = "standard"
#  }
#
#  associate_public_ip_address = true
#
#  spot_price           = var.debug_ecs_instance_price
#  wait_for_fulfillment = true
#
#  root_block_device {
#    volume_size = "20"
#    volume_type = "gp2"
#  }
#}
