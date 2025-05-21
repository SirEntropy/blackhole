resource "aws_db_instance" "bh_db" {
  identifier              = "bh-db"
  engine                  = "postgres"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  db_subnet_group_name    = "rds-subnet-group"
  vpc_security_group_ids  = ["sg-0bd925aba64f88fec"]
  publicly_accessible     = false
  storage_encrypted       = false
  backup_retention_period = 0
  auto_minor_version_upgrade = true
  preferred_maintenance_window = "wed:06:32-wed:07:02"
  maintenance_window           = "wed:06:32-wed:07:02"
  skip_final_snapshot     = true
  tags = {
    Name = "bh-db"
  }
  # Please set the following as needed:
  # username = "YOUR_DB_USERNAME"
  # password = "YOUR_DB_PASSWORD"
  # db_name  = "YOUR_DB_NAME"
}
