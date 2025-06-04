// --- Existing resources ---

// ---- Added by Cased: Unmanaged S3 migration ----
resource "aws_s3_bucket" "blackhole_classifier_terraform_state" {
  bucket = "blackhole-classifier-terraform-state"
  provider = aws
  # region: us-east-1
  # Adjust other settings, versioning, tags as needed
}

resource "aws_s3_bucket" "blackhole_ml_training" {
  bucket = "blackhole-ml-training"
  provider = aws
  # region: us-east-2
  # Adjust other settings, versioning, tags as needed
}
// ---- End Cased migration block ----

# main.tf

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  alias  = "east"
}

provider "aws" {
  region = "us-west-1"
  alias  = "west"
}

# Create S3 bucket for terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket   = "terraform-state-${random_id.bucket_suffix.hex}"
  provider = aws.east

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "Management"
  }
}

# Enable versioning for the S3 bucket
resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket   = aws_s3_bucket.terraform_state.id
  provider = aws.east

  versioning_configuration {
    status = "Enabled"
  }
}

# Create a random ID for the S3 bucket name
resource "random_id" "bucket_suffix" {
  byte_length = 8
}

resource "random_string" "redis_username" {
  length  = 16
  special = false
}

resource "random_string" "redis_password" {
  length  = 16
  special = false
}

resource "random_string" "db_username" {
  length  = 16
  special = false
}

resource "random_string" "db_password" {
  length  = 16
  special = false
}

# Create EC2 instance in us-east-1
resource "aws_instance" "east_instance" {
  ami           = "ami-04a81a99f5ec58529" # Amazon Linux 2023 AMI in us-east-1
  instance_type = "t2.micro"              # Smallest instance type
  provider      = aws.east

  tags = {
    Name = "EC2-East"
  }
}

# Create EC2 instance in us-west-2
resource "aws_instance" "west_instance" {
  ami           = "ami-0d9858aa3c6322f73" # Amazon Linux 2023 AMI in us-west-2
  instance_type = "t2.micro"              # Smallest instance type
  provider      = aws.west

  tags = {
    Name = "EC2-West"
  }
}

# Output the S3 bucket name
output "state_bucket_name" {
  value = aws_s3_bucket.terraform_state.bucket
}

# Output the EC2 instance IDs
output "east_instance_id" {
  value = aws_instance.east_instance.id
}

output "west_instance_id" {
  value = aws_instance.west_instance.id
}