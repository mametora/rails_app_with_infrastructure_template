module "vpc_endpoint_sg" {
  source              = "terraform-aws-modules/security-group/aws"
  name                = "${var.app_name}-${terraform.workspace}-vpc-endpoint"
  vpc_id              = aws_vpc.default.id
  egress_rules        = ["all-all"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["all-all"]
  tags = {
    Env     = terraform.workspace
    Product = var.app_name
  }
}

module "loadblancer_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/https-443"
  name   = "${var.app_name}-${terraform.workspace}-loadblancer"
  vpc_id = aws_vpc.default.id

  ingress_cidr_blocks = ["0.0.0.0/0"]

  tags = {
    Env     = terraform.workspace
    Product = var.app_name
  }
}

module "rails_sg" {
  source       = "terraform-aws-modules/security-group/aws"
  name         = "${var.app_name}-${terraform.workspace}-rails"
  vpc_id       = aws_vpc.default.id
  egress_rules = ["all-all"]

  tags = {
    Env     = terraform.workspace
    Product = var.app_name
  }
}

module "web_sg" {
  source = "terraform-aws-modules/security-group/aws"
  name   = "${var.app_name}-${terraform.workspace}-web"
  vpc_id = aws_vpc.default.id

  computed_ingress_with_source_security_group_id           = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.loadblancer_sg.this_security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  tags = {
    Env     = terraform.workspace
    Product = var.app_name
  }
}

module "db_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  name    = "${var.app_name}-${terraform.workspace}-db"
  vpc_id  = aws_vpc.default.id

  number_of_computed_ingress_with_source_security_group_id = 1
  computed_ingress_with_source_security_group_id           = [
    {
      rule                     = "mysql-tcp"
      source_security_group_id = module.rails_sg.this_security_group_id
    }
  ]

  tags = {
    Env     = terraform.workspace
    Product = var.app_name
  }
}

module "kvs_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  name    = "${var.app_name}-${terraform.workspace}-kvs"
  vpc_id  = aws_vpc.default.id

  number_of_computed_ingress_with_source_security_group_id = 1
  computed_ingress_with_source_security_group_id           = [
    {
      rule                     = "redis-tcp"
      source_security_group_id = module.rails_sg.this_security_group_id
    }
  ]

  tags = {
    Env     = terraform.workspace
    Product = var.app_name
  }
}
