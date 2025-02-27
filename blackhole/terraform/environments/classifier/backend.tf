terraform {
  backend "s3" {
    bucket  = "blackhole-classifier-terraform-state"
    key     = "terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
