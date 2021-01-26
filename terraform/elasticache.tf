resource "aws_elasticache_subnet_group" "default" {
  name       = "${var.app_name}-${terraform.workspace}"
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_c.id,
    aws_subnet.private_d.id
  ]
}

resource "aws_elasticache_replication_group" "default" {
  automatic_failover_enabled    = var.kvs_number_cache_clusters[terraform.workspace] > 1
  replication_group_id          = "${var.app_name}-${terraform.workspace}"
  replication_group_description = "${var.app_name} ${terraform.workspace}"
  node_type                     = var.kvs_instance_type[terraform.workspace]
  number_cache_clusters         = var.kvs_number_cache_clusters[terraform.workspace]
  parameter_group_name          = "default.redis6.x"
  port                          = 6379
  engine                        = "redis"
  engine_version                = "6.x"
  subnet_group_name             = aws_elasticache_subnet_group.default.name
  security_group_ids            = [module.kvs_sg.this_security_group_id]

  tags = {
    Name    = "${var.app_name}-${terraform.workspace}"
    Env     = terraform.workspace
    Product = var.app_name
  }

  lifecycle {
    ignore_changes = [
      number_cache_clusters,
      engine_version
    ]
  }
}
