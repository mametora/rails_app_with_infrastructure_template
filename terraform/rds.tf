resource "aws_db_subnet_group" "default" {
  name = "${var.app_name}-${terraform.workspace}"

  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_c.id,
    aws_subnet.private_d.id,
  ]

  tags = {
    Env     = terraform.workspace
    Product = var.app_name
  }
}

resource "aws_iam_service_linked_role" "rds" {
  aws_service_name = "rds.amazonaws.com"
}

resource "aws_iam_role" "enhanced_monitoring" {
  name               = "${var.app_name}-${terraform.workspace}-rds-enhanced-monitoring"
  assume_role_policy = data.aws_iam_policy_document.enhanced_monitoring.json
}

data "aws_iam_policy_document" "enhanced_monitoring" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "enhanced_monitoring" {
  role       = aws_iam_role.enhanced_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_db_instance" "default" {
  allocated_storage            = 20
  storage_type                 = "gp2"
  engine                       = "mysql"
  engine_version               = "5.7"
  instance_class               = var.db_instance_type[terraform.workspace]
  identifier                   = "${var.app_name}-${terraform.workspace}"
  skip_final_snapshot          = false
  final_snapshot_identifier    = "${var.app_name}-${terraform.workspace}-final"
  username                     = var.db_user
  password                     = random_string.db_password.result
  parameter_group_name         = "default.mysql5.7"
  auto_minor_version_upgrade   = true
  backup_retention_period      = 7
  backup_window                = "18:00-18:30"
  copy_tags_to_snapshot        = true
  db_subnet_group_name         = aws_db_subnet_group.default.name
  deletion_protection          = true
  maintenance_window           = "Sun:19:00-Sun:20:00"
  monitoring_interval          = 60
  monitoring_role_arn          = aws_iam_role.enhanced_monitoring.arn
  multi_az                     = terraform.workspace == "prod" ? true : false
  vpc_security_group_ids       = [module.db_sg.this_security_group_id]
  storage_encrypted            = true
  performance_insights_enabled = true

  tags = {
    Env     = terraform.workspace
    Product = var.app_name
  }
}
