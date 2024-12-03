# Provider configuration
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  # Recommended for production
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/ec2/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Terraform   = "true"
      Project     = var.project_name
    }
  }
}

# VPC Lookup (assuming existing VPC)
data "aws_vpc" "main" {
  tags = {
    Name = var.vpc_name
  }
}

# Subnet Lookup
data "aws_subnet" "selected" {
  vpc_id = data.aws_vpc.main.id
  tags = {
    Name = var.subnet_name
  }
}

# Security Group
resource "aws_security_group" "ec2_sg" {
  name_prefix = "${var.project_name}-ec2-sg"
  description = "Security group for EC2 instance"
  vpc_id      = data.aws_vpc.main.id

  # Example rule for SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr_blocks
    description = "SSH access"
  }

  # Add your application-specific rules here

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name_prefix = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name_prefix = "${var.project_name}-ec2-profile"
  role        = aws_iam_role.ec2_role.name
}

# Blue-Green Deployment EC2 Instances
module "blue_green" {
  source = "./modules/blue_green"

  ami_id                   = var.ami_id
  instance_type            = var.instance_type
  subnet_id                = data.aws_subnet.selected.id
  vpc_security_group_ids   = [aws_security_group.ec2_sg.id]
  iam_instance_profile     = aws_iam_instance_profile.ec2_profile.name
  assign_public_ip         = var.assign_public_ip
  root_volume_size         = var.root_volume_size
  environment              = var.environment
  project_name             = var.project_name
  allowed_ssh_cidr_blocks  = var.allowed_ssh_cidr_blocks
}

# CloudWatch Alarm for CPU Usage
resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "${var.project_name}-high-cpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "CPUUtilization"
  namespace          = "AWS/EC2"
  period             = "300"
  statistic          = "Average"
  threshold          = "80"
  alarm_description  = "This metric monitors EC2 CPU utilization"
  
  dimensions = {
    InstanceId = module.blue_green.active_instance_id
  }
}
