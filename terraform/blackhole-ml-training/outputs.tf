
output "blackhole-ml-training_id" {
  description = "ID of the S3 bucket"
  value       = aws_s3_bucket.blackhole-ml-training.id
}

output "blackhole-ml-training_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.blackhole-ml-training.arn
}

