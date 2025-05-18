
output "blackhole-classifier-terraform-state_id" {
  description = "ID of the S3 bucket"
  value       = aws_s3_bucket.blackhole-classifier-terraform-state.id
}

output "blackhole-classifier-terraform-state_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.blackhole-classifier-terraform-state.arn
}

