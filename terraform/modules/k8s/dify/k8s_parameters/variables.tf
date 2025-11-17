variable "secrets" {
  description = "A map of secrets to store in the cluster"
  type        = any
}

variable "namespace" {
  description = "The namespace to create the service account in"
  type        = string
}

