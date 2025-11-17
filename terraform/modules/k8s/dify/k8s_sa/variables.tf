variable "k8s_cluster_name" {
  description = "The name of the k8s cluster"
  type        = string
}

variable "namespace" {
  description = "The namespace to create the service account in"
  type        = string
}

variable "eks_oidc_provider_url" {
  description = "The OIDC provider URL"
  type        = string
}