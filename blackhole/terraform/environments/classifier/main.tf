
resource "aws_s3_bucket" "blackhole_classifier_terraform_state" {
  bucket = "blackhole-classifier-terraform-state"
  acl    = "private"
  tags = {
    Name = "blackhole-classifier-terraform-state"
  }
}
