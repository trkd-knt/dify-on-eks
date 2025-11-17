variable "system_name" {
  description = "The name of the system"
  type        = string
}

variable "private_subnet_ids" {
  description = "The ID of the private subnet"
  type        = list(string)
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "backup_retention_period" {
  description = "The backup retention period"
  type        = number
  default     = 7
}

variable "min_capacity" {
  description = "The minimum capacity"
  type        = number
  default     = 0
}

variable "max_capacity" {
  description = "The maximum capacity"
  type        = number
  default     = 1
}

variable "rds_instance_count" {
  description = "The number of RDS instances"
  type        = number
  default     = 1
}
