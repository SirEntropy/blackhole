output "db_cluster_endpoint" {
  description = "Connection endpoint for the database cluster"
  value       = aws_rds_cluster.default.endpoint
}

output "db_cluster_reader_endpoint" {
  description = "Reader endpoint for the database cluster"
  value       = aws_rds_cluster.default.reader_endpoint
}

output "db_cluster_name" {
  description = "Name of the database"
  value       = aws_rds_cluster.default.database_name
}

output "db_cluster_username" {
  description = "Username for the database"
  value       = aws_rds_cluster.default.master_username
}

output "db_cluster_port" {
  description = "Port of the database"
  value       = aws_rds_cluster.default.port
}