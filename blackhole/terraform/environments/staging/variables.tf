variable "aws_region" {
  description = "The AWS region to create resources in"
  default     = "us-west-2"
}

variable "org_base_name" {
  default = "cased"
}

variable "project_base_name" {
  default = "comet"
}

variable "db_name" {
  description = "Name of the RDS instance"
  default     = "staging_comet"
}

variable "db_engine_version" {
  description = "Version of the database engine"
  type        = string
  default     = "16.3" 
}

variable "environment" {
  description = "Environment (e.g., staging, production)"
  default     = "staging"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of AZs to use"
  default     = 2
}

variable "app_port" {
  description = "Port on which the app runs"
  default     = 8000
}

variable "app_count" {
  description = "Number of Docker containers to run"
  default     = 1
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision"
  default     = "2048"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "12288"
}

variable "db_instance_class" {
  description = "Instance class for the RDS instance"
  type        = string
  default     = "db.serverless"
}

variable "db_allocated_storage" {
  description = "Allocated storage for the RDS instance in gigabytes"
  type        = number
  default     = 200
}

variable "db_multi_az" {
  description = "Whether to create a multi-AZ RDS instance"
  type        = bool
  default     = false
}

variable "db_instance_count" {
  description = "Number of Aurora DB instances"
  type        = number
  default     = 1
}