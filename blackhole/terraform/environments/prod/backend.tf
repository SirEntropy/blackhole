terraform {
  backend "s3" {
    bucket  = "prod-blackhole-terraform-state"    
    key     = "prod/terraform.tfstate"
    region  = "us-east-2"
    encrypt = true
  }
}