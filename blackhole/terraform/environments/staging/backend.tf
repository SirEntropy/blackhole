terraform {
  backend "s3" {
    bucket  = "staging-blackhole-terraform-state"
    key     = "terraform.tfstate"
    region  = "us-west-1"
    encrypt = true
  }
}
