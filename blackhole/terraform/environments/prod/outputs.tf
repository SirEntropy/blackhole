output "bh_id" {
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