# Required variables
variable "aws_region" {
  description = "The AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "system_name" {
  description = "The name of the system"
  type        = string
  default     = "dify"
}

variable "spec_preset" {
  description = "The environment of the system"
  type        = string
  default     = "development"
}

# Optional variables
variable "subdomain_console" {
  description = "The subdomain for the console"
  type        = string
  default     = "admin"
}

variable "subdomain_service" {
  description = "The subdomain for the service"
  type        = string
  default     = "service"
}
