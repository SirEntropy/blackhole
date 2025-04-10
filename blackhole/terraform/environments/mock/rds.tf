# RDS Subnet Group (required for RDS)
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.instance_name_prefix}-db-subnet-group"
  subnet_ids = var.subnet_ids # Use the provided subnets

  tags = {
    Name = "${var.instance_name_prefix}-db-subnet-group"
  }
}

# RDS Database Instance
resource "aws_db_instance" "app_database" {
  identifier             = var.rds_instance_identifier  # Desired state for identifier
  instance_class         = var.rds_instance_class       # Desired state for instance class
  allocated_storage      = 20                           # Desired state for storage
  engine                 = "postgres"                   # Desired state for engine
  engine_version         = "14"                         # Desired state for engine version (use specific minor if needed)
  db_name                = var.rds_db_name              # Desired state for initial DB name
  username               = var.rds_username             # Desired state for username
  password               = local.effective_rds_password # Desired state for password (fetched from var or random)
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  parameter_group_name   = "default.postgres14" # Use appropriate default parameter group

  publicly_accessible = false # Best practice: keep DB private
  skip_final_snapshot = true  # Set to false in production! Good for demo cleanup.
  multi_az            = false # Set to true for production HA

  tags = {
    Name = var.rds_instance_identifier
    # Add other relevant tags
  }

  # If you change password outside TF, TF won't detect unless you provide the new one.
  # Sensitive fields require careful management.
  lifecycle {
    ignore_changes = [password] # Optional: Prevents TF from trying to reset password on every run if not explicitly changed in variables
  }
}
