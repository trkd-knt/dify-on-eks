resource "kubernetes_namespace" "dify" {
  metadata {
    name = "dify"

    annotations = {
      "purpose" = "dify namespace"
    }

    labels = {
      "app" = "dify"
    }
  }
}

resource "helm_release" "dify" {
  name          = "dify"
  chart         = "${path.module}/helm"
  namespace     = kubernetes_namespace.dify.metadata[0].name
  force_update  = true
  recreate_pods = true

  values = [
    yamlencode({
      computeType = var.auto_mode_is_enabled ? "auto" : "ec2"
      domains = {
        siteDomain = var.domains.hosted_zone_name
        console = try(var.domains.console, null)
        service = try(var.domains.service, null)
        certArn = var.eks_cluster_configs.cert_arn
      }
      volume = {
        s3Bucket  = var.s3_bucket_name
        awsRegion = data.aws_region.current.name
      }
      dummy = "dummy"
    })
  ]

  wait = false
  wait_for_jobs = false
}

module "k8s_parameters" {
  source = "./k8s_parameters"

  secrets   = var.secrets
  namespace = kubernetes_namespace.dify.metadata[0].name
}

module "k8s_sa" {
  source = "./k8s_sa"

  k8s_cluster_name      = var.eks_cluster_configs.cluster_name
  namespace             = kubernetes_namespace.dify.metadata[0].name
  eks_oidc_provider_url = var.eks_cluster_configs.eks_oidc_provider.url
}

data "aws_region" "current" {}
