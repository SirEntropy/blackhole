output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.prod_vpc.id
}

output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.app_alb.dns_name
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.prod_db.endpoint
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.storage.id
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.app_asg.name
}