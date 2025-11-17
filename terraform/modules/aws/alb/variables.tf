variable "system_name" {
  description = "The name of the system"
  type        = string
}

variable "public_subnet_ids" {
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

variable "use_custom_domain" {
  description = "Use a custom domain"
  type        = bool
}

variable "hosted_zone_name" {
  description = "The hosted zone name"
  type        = string
  default    = null
}
