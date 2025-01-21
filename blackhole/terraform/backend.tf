terraform {
  backend "s3" {
    bucket  = "staging-cased-terraform-state"
    key     = "staging/terraform.tfstate"
    region  = "us-west-2"
    encrypt = true
  }
}
