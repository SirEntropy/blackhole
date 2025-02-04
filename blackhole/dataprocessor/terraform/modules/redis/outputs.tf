output "redis_connection_string" {
  value     = "rediss://${var.redis_username}:${var.redis_password}@${aws_elasticache_replication_group.default.primary_endpoint_address}:${var.redis_port}/0"
  sensitive = true
}

output "redis_host" {
  value = aws_elasticache_replication_group.default.primary_endpoint_address
}

output "redis_port" {
  value = var.redis_port
}

output "redis_sg_id" {
  value = aws_security_group.redis.id
}

output "redis_username" {
  value = var.redis_username
}