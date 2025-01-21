provider "aws" {
  region = var.aws_region
}

# VPC Configuration
resource "aws_vpc" "prod_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name        = "production-vpc"
    Environment = var.environment
  }
}

# Public Subnets in different AZs
resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.prod_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"
  
  tags = {
    Name = "prod-public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.prod_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}b"
  
  tags = {
    Name = "prod-public-subnet-2"
  }
}

# Private Subnets
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.prod_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.aws_region}a"
  
  tags = {
    Name = "prod-private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.prod_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "${var.aws_region}b"
  
  tags = {
    Name = "prod-private-subnet-2"
  }
}

# Security Groups
resource "aws_security_group" "alb_sg" {
  name        = "prod-alb-sg"
  description = "Security group for application load balancer"
  vpc_id      = aws_vpc.prod_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "app_sg" {
  name        = "prod-app-sg"
  description = "Security group for application servers"
  vpc_id      = aws_vpc.prod_vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # VPC CIDR only
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch Template
resource "aws_launch_template" "app_template" {
  name_prefix   = "prod-app-template"
  image_id      = "ami-0c55b159cbfafe1f0"  # Should use data source
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = false
    security_groups            = [aws_security_group.app_sg.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo "Production server" > index.html
              nohup python -m SimpleHTTPServer 80 &
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "prod-app-server"
      Environment = var.environment
    }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "app_asg" {
  desired_capacity    = 2
  max_size           = 4
  min_size           = 2
  target_group_arns  = [aws_lb_target_group.app_tg.arn]
  vpc_zone_identifier = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  launch_template {
    id      = aws_launch_template.app_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }
}

# Application Load Balancer
resource "aws_lb" "app_alb" {
  name               = "prod-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets           = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
}

resource "aws_lb_target_group" "app_tg" {
  name     = "prod-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.prod_vpc.id
}

# RDS Instance - Multi-AZ
resource "aws_db_instance" "prod_db" {
  identifier        = "prod-db"
  allocated_storage = 100
  engine           = "postgres"
  engine_version   = "13.7"
  instance_class   = "db.t3.large"
  username         = var.db_username
  password         = var.db_password
  
  multi_az         = var.multi_az
  backup_retention_period = 7
  
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.prod_db_subnet.name
  
  tags = {
    Environment = var.environment
  }
}

resource "aws_db_subnet_group" "prod_db_subnet" {
  name       = "prod-db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
}

# S3 Bucket with encryption
resource "aws_s3_bucket" "storage" {
  bucket = "prod-storage-bucket"
  
  tags = {
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "storage" {
  bucket = aws_s3_bucket.storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "storage" {
  bucket = aws_s3_bucket.storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "storage" {
  bucket = aws_s3_bucket.storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}