terraform {
  required_version = "~> v1.9.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host                   = module.aws.eks_cluster_configs.k8s_endpoint
  cluster_ca_certificate = module.aws.eks_cluster_configs.cluster_ca_certificate
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.aws.eks_cluster_configs.cluster_name]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = module.aws.eks_cluster_configs.k8s_endpoint
    cluster_ca_certificate = module.aws.eks_cluster_configs.cluster_ca_certificate
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.aws.eks_cluster_configs.cluster_name]
      command     = "aws"
    }
  }
}

# provider "kubernetes" {
#   config_path = "~/.kube/config"
# }
# 
# provider "helm" {
#   kubernetes {
#     config_path = "~/.kube/config"
#   }
# }
# 
# output "eks_endpoint" {
#   value = module.aws.eks_cluster_configs.k8s_endpoint
# }
# 
# output "cluster_ca_certificate" {
#   value = module.aws.eks_cluster_configs.cluster_ca_certificate
# }
# 
# output "eks_cluster_name" {
#   value = module.aws.eks_cluster_configs.cluster_name
# }
