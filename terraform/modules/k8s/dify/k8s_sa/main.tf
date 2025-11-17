resource "aws_iam_role" "dify_api" {
  name = "${var.k8s_cluster_name}-pod-role-dify"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.id}:oidc-provider/${trimprefix(var.eks_oidc_provider_url, "https://")}"
        }
        Condition = {
          StringEquals = {
            "${trimprefix(var.eks_oidc_provider_url, "https://")}:sub" = "system:serviceaccount:dify:dify-api"
            "${trimprefix(var.eks_oidc_provider_url, "https://")}:aud" = "sts.amazonaws.com"
          }
        }
        Effect = "Allow"
      },
    ]
  })

  lifecycle {
    ignore_changes = [ assume_role_policy ]
  }
}

resource "aws_iam_policy" "dify_api" {
  name        = "${var.k8s_cluster_name}-pod-policy-dify-api"
  description = "Policy for DIFY pods"

  policy = file("${path.module}/policies/dify-api.json")
}

resource "aws_iam_role_policy_attachment" "policy_attachment_dify_api" {
  policy_arn = aws_iam_policy.dify_api.arn
  role       = aws_iam_role.dify_api.name
}

resource "kubernetes_service_account" "dify_api" {
  metadata {
    name      = "dify-api"
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.dify_api.arn
    }
  }
}

data "aws_caller_identity" "current" {}
