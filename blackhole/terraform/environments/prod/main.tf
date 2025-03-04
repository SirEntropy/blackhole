resource "aws_s3_bucket" "bh" {
  bucket = "bh"
  acl    = "private"
  
  versioning {
    enabled = true
  }
  
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  
  lifecycle_rule {
    id      = "archive-old-objects"
    enabled = true
    
    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }
    
    transition {
      days          = 365
      storage_class = "GLACIER"
    }
  }
  
  tags = {
    Name = "bh"
    "Environment" = "Production"
  }
}


resource "aws_s3_bucket_policy" "bh_policy" {
  bucket = aws_s3_bucket.bh.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyHTTP"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.bh.arn,
          "${aws_s3_bucket.bh.arn}/*",
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport": "false"
          }
        }
      }
    ]
  })
}