resource "aws_s3_bucket" "service_artifacts" {
  bucket = "${var.environment}-service-artifacts-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "${var.environment}-service-artifacts"
  }
}

resource "aws_s3_bucket_versioning" "service_artifacts" {
  bucket = aws_s3_bucket.service_artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "service_artifacts" {
  bucket = aws_s3_bucket.service_artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
