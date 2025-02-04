variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "ecs_sg_id" {
  description = "Security group ID for ECS tasks"
  type        = string
}

variable "db_engine_version" {
  description = "Version of the database engine"
  type        = string
}

variable "db_instance_class" {
  description = "Instance class for the Aurora instances"
  type        = string
  default     = "db.serverless"
}

variable "db_name" {
  description = "Name of the database to create"
  type        = string
}

variable "db_username" {
  description = "Username for the database"
  type        = string
}

variable "db_password" {
  description = "Password for the database"
  type        = string
  sensitive   = true
}

variable "availability_zones" {
  description = "A list of availability zones for the RDS cluster"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]  
}

variable "db_instance_count" {
  description = "Number of database instances in the cluster"
  type        = number
  default     = 2
}

variable "db_min_capacity" {
  description = "The minimum capacity for Aurora Serverless v2 in Aurora Capacity Units (ACUs)"
  type        = number
  default     = 0.5
}

variable "db_max_capacity" {
  description = "The maximum capacity for Aurora Serverless v2 in Aurora Capacity Units (ACUs)"
  type        = number
  default     = 128
}

variable "aurora_ingress_rules" {
  type = list(object({
    from_port       = number
    to_port         = number
    protocol        = string
    security_groups = list(string)
  }))
  default = [
    {
      from_port       = 5432
      to_port         = 5432
      protocol        = "tcp"
      security_groups = ["sg-050b103edd55b90d7", "sg-096df05075419e13e"]
    },
    {
      from_port       = 5432
      to_port         = 5432
      protocol        = "tcp"
      security_groups = ["sg-0e1f1b5287977556e"]
    }
  ]
}