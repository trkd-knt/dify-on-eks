variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "eks_cluster_configs" {
  description = "The EKS cluster configurations"
  type        = any
}