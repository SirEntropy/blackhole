variable "aws_regions" {
  description = "AWS regions for deployment"
  type        = map(string)
  default = {
    east = "us-east-1"
    west = "us-west-2"
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

# Note: AMI IDs are region-specific and should be updated if using different regions
variable "amis" {
  description = "AMIs for each region (Amazon Linux 2023)"
  type        = map(string)
  default = {
    "us-east-1" = "ami-04a81a99f5ec58529"
    "us-west-1" = "ami-0d9858aa3c6322f73"
  }
}
