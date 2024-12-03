variable "ami_id" {
  description = "AMI ID to use for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the EC2 instances"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs to associate"
  type        = list(string)
}

variable "iam_instance_profile" {
  description = "IAM instance profile to associate with the instances"
  type        = string
}

variable "assign_public_ip" {
  description = "Whether to assign a public IP to the instances"
  type        = bool
}

variable "root_volume_size" {
  description = "Size of the root volume in GB"
  type        = number
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "allowed_ssh_cidr_blocks" {
  description = "List of CIDR blocks allowed to SSH to the instance"
  type        = list(string)
}

variable "blue_green_instances" {
  description = "Number of instances for blue-green deployment"
  type        = number
}
