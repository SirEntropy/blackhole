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
