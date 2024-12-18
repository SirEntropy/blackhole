output "rds_endpoint" {
  description = "The connection endpoint for the Aurora cluster"
  value       = module.rds.db_cluster_endpoint
  sensitive   = true
}

output "rds_reader_endpoint" {
  description = "The reader endpoint for the Aurora cluster"
  value       = module.rds.db_cluster_reader_endpoint
  sensitive   = true
}

output "rds_database_name" {
  description = "The name of the database"
  value       = module.rds.db_cluster_name
}

output "rds_username" {
  description = "The master username for the database"
  value       = module.rds.db_cluster_username
  sensitive   = true
}

output "rds_port" {
  description = "The port the database is listening on"
  value       = module.rds.db_cluster_port
}

output "database_url" {
  description = "The connection URL for the database"
  value       = "postgresql://${random_string.db_username.result}:${random_password.db_password.result}@${module.rds.db_cluster_endpoint}/${var.db_name}"
  sensitive   = true
}
