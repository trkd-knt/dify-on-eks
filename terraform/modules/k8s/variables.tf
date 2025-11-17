variable "system_name" {
  description = "The name of the system"
  type        = string
}

variable "specs" {
  description = "The specs of the system"
  type        = any
}

variable "domains" {
  description = "The domain of the system"
  type        = any
}

variable "network_configs" {
  description = "The network configurations"
  type        = any
}

variable "eks_cluster_configs" {
  description = "The EKS cluster configurations"
  type        = any
}

variable "db_configs" {
  description = "The DB configurations"
  type        = any
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}
