variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "auto_mode_is_enabled" {
  description = "Enable the auto mode"
  type        = bool
}

variable "s3_mount_ops_is_enabled" {
  description = "Enable the s3 mount ops"
  type        = bool
}

variable "eks_cluster_configs" {
  description = "The EKS cluster configurations"
  type        = any
}
