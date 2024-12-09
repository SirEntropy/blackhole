# variables.tf
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "vpc_name" {
  description = "Name tag of the VPC to use"
  type        = string
}

variable "subnet_name" {
  description = "Name tag of the subnet to use"
  type        = string
}

variable "ami_id" {
  description = "AMI ID to use for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "root_volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 50
}

variable "assign_public_ip" {
  description = "Whether to assign a public IP to the instance"
  type        = bool
  default     = false
}

variable "allowed_ssh_cidr_blocks" {
  description = "List of CIDR blocks allowed to SSH to the instance"
  type        = list(string)
  default     = []
}

variable "rds_allocated_storage" {
  description = "The allocated storage in gigabytes"
  type        = number
  default     = 20
}

variable "rds_engine" {
  description = "The database engine to use"
  type        = string
  default     = "mysql"
}

variable "rds_engine_version" {
  description = "The engine version to use"
  type        = string
  default     = "8.0"
}

variable "rds_instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_db_name" {
  description = "The name of the database to create"
  type        = string
  default     = "mydb"
}

variable "rds_username" {
  description = "The username for the database"
  type        = string
  default     = "admin"
}

variable "rds_password" {
  description = "The password for the database"
  type        = string
  default     = "changeMe123"
  sensitive   = true
}

variable "rds_parameter_group_name" {
  description = "The name of the DB parameter group to associate"
  type        = string
  default     = "default.mysql8.0"
}
