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

# EC2 Instances for Blue-Green Deployment
resource "aws_instance" "blue" {
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id                   = data.aws_subnet.selected.id
  vpc_security_group_ids     = [aws_security_group.ec2_sg.id]
  iam_instance_profile       = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = var.assign_public_ip

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    encrypted            = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"  # IMDSv2
    http_put_response_hop_limit = 1
  }

  monitoring = true  # Detailed monitoring

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    environment = var.environment
  }))

  lifecycle {
    ignore_changes = [ami]  # Ignore AMI changes for manual updates
  }
}

resource "aws_instance" "green" {
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id                   = data.aws_subnet.selected.id
  vpc_security_group_ids     = [aws_security_group.ec2_sg.id]
  iam_instance_profile       = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = var.assign_public_ip

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    encrypted            = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"  # IMDSv2
    http_put_response_hop_limit = 1
  }

  monitoring = true  # Detailed monitoring

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    environment = var.environment
  }))

  lifecycle {
    ignore_changes = [ami]  # Ignore AMI changes for manual updates
  }
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
    InstanceId = aws_instance.blue.id  # Monitor the blue instance
  }
}

# Elastic Load Balancer for Blue-Green Deployment
resource "aws_lb" "main" {
  name               = "${var.project_name}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ec2_sg.id]
  subnets            = [data.aws_subnet.selected.id]

  enable_deletion_protection = true
}

resource "aws_lb_target_group" "blue" {
  name     = "${var.project_name}-blue-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-299"
  }
}

resource "aws_lb_target_group" "green" {
  name     = "${var.project_name}-green-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-299"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn  # Start with blue
  }
}

resource "aws_lb_target_group_attachment" "blue" {
  target_group_arn = aws_lb_target_group.blue.arn
  target_id        = aws_instance.blue.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "green" {
  target_group_arn = aws_lb_target_group.green.arn
  target_id        = aws_instance.green.id
  port             = 80
}
