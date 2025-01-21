# Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.staging_vpc.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public_subnet.id
}

output "ec2_instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.staging_db.endpoint
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.storage.id
}

output "security_group_id" {
  description = "ID of the main security group"
  value       = aws_security_group.app_sg.id
}


