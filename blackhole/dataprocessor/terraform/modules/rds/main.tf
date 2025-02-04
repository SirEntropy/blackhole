resource "aws_db_subnet_group" "default" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_subnets

  tags = {
    Name = "${var.project_name} DB subnet group"
  }
}

resource "aws_rds_cluster" "default" {
  cluster_identifier      = "${var.project_name}-aurora-cluster"
  engine                  = "aurora-postgresql"
  engine_version          = var.db_engine_version
  engine_mode             = "provisioned"
  availability_zones      = var.availability_zones
  database_name           = var.db_name
  master_username         = var.db_username
  master_password         = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.default.name
  vpc_security_group_ids  = [aws_security_group.aurora.id]
  skip_final_snapshot     = true
  enable_http_endpoint    = true  # This enables the Data API

  serverlessv2_scaling_configuration {
    min_capacity = var.db_min_capacity
    max_capacity = var.db_max_capacity
  }

  lifecycle {
    ignore_changes = [availability_zones]
  }


  tags = {
    Name = "${var.project_name} Aurora Cluster"
  }
}

resource "aws_rds_cluster_instance" "default" {
  count               = min(var.db_instance_count, 3)
  identifier          = "${var.project_name}-aurora-instance-${count.index + 1}"
  cluster_identifier  = aws_rds_cluster.default.id
  instance_class      = var.db_instance_class
  engine              = aws_rds_cluster.default.engine
  engine_version      = aws_rds_cluster.default.engine_version

  tags = {
    Name = "${var.project_name} Aurora Instance ${count.index + 1}"
  }
}

resource "aws_security_group" "aurora" {
  name        = "${var.project_name}-aurora-sg"
  description = "Allow inbound traffic to Aurora"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.aurora_ingress_rules
    content {
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      security_groups = ingress.value.security_groups
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name} Aurora security group"
  }

  lifecycle {
    ignore_changes = [ingress]
  }
}

resource "aws_iam_role" "rds_data_api_role" {
  name = "${var.project_name}-rds-data-api-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_data_api_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSDataFullAccess"
  role       = aws_iam_role.rds_data_api_role.name
}
