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
  default     = "prod_comet"
}

variable "db_engine_version" {
  description = "Version of the database engine"
  type        = string
  default     = "16.3" 
}

variable "environment" {
  description = "Environment (e.g., staging, prod)"
  default     = "prod"
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
  default     = 2
}

variable "enable_autoscaling" {
  description = "Whether to enable autoscaling for the ECS service"
  type        = bool
  default     = true
}

variable "autoscaling_min_capacity" {
  description = "Minimum number of tasks to run in the service when autoscaling is enabled"
  type        = number
  default     = 1
}

variable "autoscaling_max_capacity" {
  description = "Maximum number of tasks to run in the service when autoscaling is enabled"
  type        = number
  default     = 4
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision"
  default     = "4096"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "24576"
}

variable "db_instance_class" {
  description = "Instance class for the RDS instance"
  type        = string
  default     = "db.serverless"
}

variable "db_allocated_storage" {
  description = "Allocated storage for the RDS instance in gigabytes"
  type        = number
  default     = 1000
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