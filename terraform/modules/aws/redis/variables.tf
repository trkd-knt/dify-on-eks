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

variable "max_storage_gigabytes" {
  description = "The maximum storage in gigabytes"
  type        = number
  default     = 10
}

variable "daily_snapshot_time" {
  description = "The daily snapshot time"
  type        = string
  default     = "09:00"
}

variable "backup_retention_period" {
  description = "The backup retention period"
  type        = number
  default     = 7
}
