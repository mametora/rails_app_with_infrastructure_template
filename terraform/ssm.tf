resource "aws_ssm_parameter" "web_host" {
  name  = "/${terraform.workspace}/web_host"
  type  = "String"
  value = var.domain_name[terraform.workspace]
}

resource "aws_ssm_parameter" "db_host" {
  name  = "/${terraform.workspace}/db/host"
  type  = "String"
  value = aws_db_instance.default.address
}

resource "aws_ssm_parameter" "db_user" {
  name        = "/${terraform.workspace}/db/user"
  type        = "String"
  value       = aws_db_instance.default.username
  description = "db user name"
}

resource "aws_ssm_parameter" "db_password" {
  name  = "/${terraform.workspace}/db/password"
  type  = "SecureString"
  value = aws_db_instance.default.password
}

resource "aws_ssm_parameter" "kvs_host" {
  name  = "/${terraform.workspace}/kvs/host"
  type  = "String"
  value = aws_elasticache_replication_group.default.primary_endpoint_address
}

resource "aws_ssm_parameter" "bucket" {
  name  = "/${terraform.workspace}/bucket"
  type  = "String"
  value = aws_s3_bucket.default.id
}

resource "aws_ssm_parameter" "rails_master_key" {
  name  = "/${terraform.workspace}/rails/master_key"
  type  = "SecureString"
  value = file("../config/master.key")
}
