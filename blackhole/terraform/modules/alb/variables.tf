variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "health_check_path" {
  description = "Path for ALB health check"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the ALB"
  type        = string
}

variable "route53_zone_id" {
  description = "The Route 53 Hosted Zone ID for the domain"
  type        = string
}

variable "create_certificate" {
  description = "Whether to create a new certificate or use an existing one"
  type        = bool
  default     = true
}

variable "certificate_arn" {
  description = "ARN of an existing certificate to use (if not creating a new one)"
  type        = string
  default     = ""
}
