resource "aws_elasticache_subnet_group" "default" {
  name       = "${var.project_name}-redis-subnet-group"
  subnet_ids = var.private_subnets
}

resource "aws_elasticache_parameter_group" "redis_with_persistence" {
  family = var.redis_parameter_group_family
  name   = "${var.project_name}-redis-params"

  parameter {
    name  = "maxmemory-policy"
    value = var.redis_maxmemory_policy
  }
}

data "aws_elasticache_user" "default_user" {
  user_id = "default"
}

resource "aws_elasticache_user" "custom_user" {
  user_id       = "${var.project_name}-custom-user"
  user_name     = var.redis_username
  access_string = "on ~* +@all"
  engine        = "REDIS"
  passwords     = [var.redis_password]
}

resource "aws_elasticache_user_group" "redis_user_group" {
  engine        = "REDIS"
  user_group_id = "${var.project_name}-user-group"
  user_ids      = [data.aws_elasticache_user.default_user.user_id, aws_elasticache_user.custom_user.user_id]
}

resource "aws_elasticache_replication_group" "default" {
  replication_group_id          = "${var.project_name}-redis"
  description                   = "${var.project_name} Redis cluster"
  node_type                     = var.redis_node_type
  num_cache_clusters            = var.redis_num_cache_nodes
  parameter_group_name          = aws_elasticache_parameter_group.redis_with_persistence.name
  port                          = var.redis_port
  subnet_group_name             = aws_elasticache_subnet_group.default.name
  security_group_ids            = [aws_security_group.redis.id]
  
  automatic_failover_enabled    = true
  multi_az_enabled              = true

  at_rest_encryption_enabled    = var.redis_at_rest_encryption
  transit_encryption_enabled    = var.redis_transit_encryption

  user_group_ids                = [aws_elasticache_user_group.redis_user_group.id]

  engine_version                = var.redis_engine_version
  engine                        = "redis"
  maintenance_window            = var.redis_maintenance_window
  snapshot_window               = var.redis_snapshot_window
  snapshot_retention_limit      = var.redis_snapshot_retention_limit
}

resource "aws_security_group" "redis" {
  name        = "${var.project_name}-redis-sg"
  description = "Allow inbound traffic from ECS tasks to Redis"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.redis_port
    to_port         = var.redis_port
    protocol        = "tcp"
    security_groups = [var.ecs_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}