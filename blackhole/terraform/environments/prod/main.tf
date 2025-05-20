
resource "aws_s3_bucket" "blackhole_ml_training" {
  bucket = "blackhole-ml-training"
  acl    = "private"
  tags = {
    Name = "blackhole-ml-training"
  }
}
