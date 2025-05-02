
resource "aws_s3_bucket" "blackhole-ml-training" {
  bucket = "blackhole-ml-training"
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


  tags = {
    Name = "blackhole-ml-training"
    Environment = "Development"
  }
}

