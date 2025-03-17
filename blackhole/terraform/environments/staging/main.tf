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


# Add AWS Budgets for cost control
resource "aws_budgets_budget" "monthly_budget" {
  name              = "Monthly Budget"
  budget_type       = "COST"
  limit_amount      = "100"
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  cost_filters      = {}
  cost_types        = {}
  time_period_start = "2023-01-01_00:00"
  time_period_end   = "2023-12-31_23:59"

  notification {
    comparison_operator = "GREATER_THAN"
    notification_type   = "ACTUAL"
    threshold           = 80
    threshold_type      = "PERCENTAGE"

    subscriber {
      address          = "example@example.com"
      subscription_type = "EMAIL"
    }
  }
}