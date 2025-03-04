variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-west-1"
}

variable "cluster_name" {
  description = "blackhole-classifier"
  type        = string
  default     = "minimal-eks-cluster"
}


variable "subnet_id" {
  description = "Subnet ID where the EC2 instance will be launched"
  type        = string
}

variable "security_group_id" {
  description = "Security Group ID for the EC2 instance"
  type        = string
}

variable "key_name" {
  description = "SSH key name for EC2 instance access"
  type        = string
}

