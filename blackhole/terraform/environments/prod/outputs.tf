output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

output "ec2_instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.database.endpoint
}

output "elasticache_endpoint" {
  description = "ElastiCache cluster endpoint"
  value       = aws_elasticache_cluster.redis.cache_nodes[0].address
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.app.repository_url
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.app_data.id
}output "bh_id" {
  description = "ID of the S3 bucket"
  value       = aws_s3_bucket.bh.id
}

output "bh_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.bh.arn
}

output "bh_region" {
  description = "Region of the S3 bucket"
  value       = aws_s3_bucket.bh.region
}