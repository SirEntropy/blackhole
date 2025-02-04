variable "project_name" {}
variable "vpc_cidr" {}
variable "az_count" {}
variable "aws_region" {
  description = "The AWS region to create resources in"
  type        = string
}