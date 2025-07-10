variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the RDS and ElastiCache clusters"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "cache_node_type" {
  description = "ElastiCache node type"
  type        = string
  default     = "cache.t3.micro"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "trusted_ssh_cidrs" {
  description = "List of CIDR blocks allowed to access SSH (port 22). Defaults to private networks only."
  type        = list(string)
  default = [
    "10.0.0.0/8",      # Private network (Class A)
    "172.16.0.0/12",   # Private network (Class B) 
    "192.168.0.0/16",  # Private network (Class C)
  ]
  validation {
    condition = length(var.trusted_ssh_cidrs) > 0
    error_message = "At least one CIDR block must be specified for SSH access."
  }
}