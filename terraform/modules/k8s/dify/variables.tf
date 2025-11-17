variable "secrets" {
  description = "A map of secrets to store in the cluster"
  type        = any
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "domains" {
  description = "A list of domains to use"
  type        = any
}

variable "eks_cluster_configs" {
  description = "The EKS cluster configurations"
  type        = any
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "auto_mode_is_enabled" {
  description = "Whether auto mode is enabled"
  type        = bool
}
