variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "ID of the existing VPC where resources should be deployed"
  type        = string
  # No default - this should be provided based on the environment
}

variable "subnet_ids" {
  description = "List of existing Subnet IDs within the VPC"
  type        = list(string)
  # No default - provide appropriate private/public subnets
  # Example: ["subnet-xxxxxxxxxxxxxxxxx", "subnet-yyyyyyyyyyyyyyyyy"]
}

variable "instance_name_prefix" {
  description = "Prefix for naming resources"
  type        = string
  default     = "devops-agent-demo"
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro" # Common point of drift
}

variable "ecs_cluster_name" {
  description = "Name for the ECS Cluster"
  type        = string
  default     = "demo-app-cluster"
}

variable "rds_instance_identifier" {
  description = "Identifier for the RDS instance"
  type        = string
  default     = "demo-app-db"
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro" # Common point of drift
}

variable "rds_db_name" {
  description = "Name for the initial database within the RDS instance"
  type        = string
  default     = "myappdb"
}

variable "rds_username" {
  description = "Master username for the RDS instance"
  type        = string
  default     = "dbadmin"
}

variable "rds_password" {
  description = "Master password for the RDS instance. IMPORTANT: Use a secrets manager in production!"
  type        = string
  sensitive   = true
  # No default - should be generated or securely provided
}

# --- Example using random provider for password generation if not provided ---
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

locals {
  # Use provided password if not empty, otherwise use the generated one
  effective_rds_password = var.rds_password != "" ? var.rds_password : random_password.db_password.result
}
