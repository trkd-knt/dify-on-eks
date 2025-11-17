variable "system_name" {
  description = "The name of the system"
  type        = string
}

variable "private_subnet_ids" {
  description = "The ID of the private subnet"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "The ID of the public subnet"
  type        = list(string)
}

variable "auto_mode_is_enabled" {
  description = "Whether auto mode is enabled"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "The number of days to retain log events"
  type        = number
  default     = 7
}

variable "min_node_count" {
  description = "The minimum number of nodes"
  type        = number
  default     = 2
}

variable "max_node_count" {
  description = "The maximum number of nodes"
  type        = number
  default     = 5
}