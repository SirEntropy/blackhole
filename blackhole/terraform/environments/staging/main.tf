provider "aws" {
  region = var.aws_region
}

# VPC Configuration
resource "aws_vpc" "staging_vpc" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "staging-vpc"
    Environment = "staging"
  }
}

# Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.staging_vpc.id
  cidr_block = "10.0.1.0/24"
  
  tags = {
    Name = "staging-public-subnet"
  }
}

# Security Group
resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Security group for application servers"
  vpc_id      = aws_vpc.staging_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Not recommended for production
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "app_server" {
  ami           = "ami-0c55b159cbfafe1f0"  # Ubuntu 20.04 LTS
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id
  
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  
  root_block_device {
    volume_size = 8
  }
  
  tags = {
    Name = "staging-app-server"
    Environment = "staging"
  }
}

# RDS Instance
resource "aws_db_instance" "staging_db" {
  identifier        = "staging-db"
  allocated_storage = 20
  engine           = "postgres"
  engine_version   = "13.7"
  instance_class   = "db.t3.micro"
  username         = "admin"
  password         = "password123"  # Bad practice - should use secrets management
  
  skip_final_snapshot = true
  
  tags = {
    Environment = "staging"
  }
}

# S3 Bucket
resource "aws_s3_bucket" "storage" {
  bucket = "staging-storage-bucket"
  
  tags = {
    Environment = "staging"
  }
}

# Allow public access to S3 bucket (not recommended for production)
resource "aws_s3_bucket_public_access_block" "storage" {
  bucket = aws_s3_bucket.storage.id

  block_public_acls   = false
  block_public_policy = false
  ignore_public_acls  = false
  restrict_public_buckets = false
}