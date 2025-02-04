terraform {
  backend "s3" {
    bucket  = "prod-cased-terraform-state"    
    key     = "prod/terraform.tfstate"
    region  = "us-west-2"
    encrypt = true
  }
}