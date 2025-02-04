variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
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

variable "app_port" {
  description = "Port on which the app runs"
  type        = number
}

variable "app_count" {
  description = "Number of Docker containers to run"
  type        = number
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision"
  type        = string
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  type        = string
}

variable "ecr_repo_url" {
  description = "URL of the ECR repository"
  type        = string
}

variable "aws_region" {
  description = "The AWS region to create resources in"
  type        = string
}

variable "alb_target_group_arn" {
  description = "ARN of the ALB target group"
  type        = string
}

variable "alb_listener_http" {
  description = "ARN of the ALB HTTP listener"
  type        = string
}

variable "alb_listener_https" {
  description = "ARN of the ALB HTTPS listener"
  type        = string
}

variable "alb_security_group_id" {
  description = "ID of the ALB security group"
  type        = string
}

variable "ssm_parameter_arns" {
  description = "Map of SSM parameter names to their ARNs"
  type        = map(string)
}

variable "datadog_api_key_ssm_parameter_arn" {
  description = "ARN of the Datadog API key SSM parameter"
  type        = string
  default     = "arn:aws:ssm:us-west-2:495860673956:parameter/prod-comet/DATADOG_API_KEY"
}
