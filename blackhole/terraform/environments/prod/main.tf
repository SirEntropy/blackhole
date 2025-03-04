resource "aws_instance" "app_server" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  subnet_id     = var.subnet_ids[0]

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  monitoring = true

  tags = {
    Name = "${var.environment}-app-server"
  }
}

# RDS Instance
resource "aws_db_instance" "database" {
  identifier        = "${var.environment}-database"
  engine            = "postgres"
  engine_version    = "14"
  username          = var.db_username
  password          = var.db_password
  instance_class    = var.db_instance_class
  allocated_storage = 20
  storage_type      = "gp3"

  multi_az               = true
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.database.id]

  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "Mon:04:00-Mon:05:00"

  storage_encrypted = true
  
  deletion_protection = true
  skip_final_snapshot = false

  tags = {
    Name = "${var.environment}-database"
  }
}

# ElastiCache Cluster
resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.environment}-redis"
  engine              = "redis"
  node_type           = var.cache_node_type
  num_cache_nodes     = 1
  parameter_group_name = "default.redis7"
  port                = 6379
  
  subnet_group_name    = aws_elasticache_subnet_group.default.name
  security_group_ids   = [aws_security_group.cache.id]

  snapshot_retention_limit = 7
  snapshot_window         = "05:00-06:00"
  maintenance_window      = "sun:06:00-sun:07:00"

  tags = {
    Name = "${var.environment}-redis"
  }
}

# ECR Repository
resource "aws_ecr_repository" "app" {
  name = "${var.environment}-app"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
  }
}

# S3 Bucket
resource "aws_s3_bucket" "app_data" {
  bucket = "${var.environment}-app-data-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "${var.environment}-app-data"
  }
}

resource "aws_s3_bucket_versioning" "app_data" {
  bucket = aws_s3_bucket.app_data.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "app_data" {
  bucket = aws_s3_bucket.app_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Supporting resources
resource "aws_db_subnet_group" "default" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.environment}-db-subnet-group"
  }
}

resource "aws_elasticache_subnet_group" "default" {
  name       = "${var.environment}-cache-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.environment}-cache-subnet-group"
  }
}

# Security Groups
resource "aws_security_group" "app" {
  name_prefix = "${var.environment}-app-"
  description = "Security group for application server"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # You might want to restrict this to your IP
    description = "SSH access"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.environment}-app"
  }
}

resource "aws_security_group" "database" {
  name_prefix = "${var.environment}-database-"
  description = "Security group for RDS instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
    description     = "PostgreSQL access from app servers"
  }

  tags = {
    Name = "${var.environment}-database"
  }
}

resource "aws_security_group" "cache" {
  name_prefix = "${var.environment}-cache-"
  description = "Security group for ElastiCache cluster"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
    description     = "Redis access from app servers"
  }

  tags = {
    Name = "${var.environment}-cache"
  }
}

# Data sources
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_caller_identity" "current" {}
resource "aws_instance" "astro" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.large"
  subnet_id     = ${var.subnet_id}
  vpc_security_group_ids = ["${var.security_group_id}"]
  key_name      = ${var.key_name}

  root_block_device {
    volume_size = 100
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name = "astro"
    Environment = "Production"
  }
}

