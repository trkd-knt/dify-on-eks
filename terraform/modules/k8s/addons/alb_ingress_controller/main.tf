resource "helm_release" "alb_ingress_controller" {
  name = "aws-alb-ingress-controller"

  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"

  wait_for_jobs = true

  set {
    name  = "clusterName"
    value = var.eks_cluster_configs.cluster_name
  }
  set {
    name  = "region"
    value = data.aws_region.current.name
  }
  set {
    name  = "vpcId"
    value = var.vpc_id
  }
  set {
    name  = "serviceAccount.create"
    value = false
  }
  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.alb_ingress_controller.metadata[0].name
  }
}

resource "aws_iam_role" "alb_ingress_controller" {
  name = "${var.eks_cluster_configs.cluster_name}-alb-ingress-ctl-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.id}:oidc-provider/${trimprefix(var.eks_cluster_configs.eks_oidc_provider.url, "https://")}"
        }
        Condition = {
          StringEquals = {
            "${trimprefix(var.eks_cluster_configs.eks_oidc_provider.url, "https://")}:sub" = "system:serviceaccount:kube-system:alb-ingress-controller"
            "${trimprefix(var.eks_cluster_configs.eks_oidc_provider.url, "https://")}:aud" = "sts.amazonaws.com"
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

resource "aws_iam_policy" "alb_ingress_controller_policy" {
  name        = "ALBIngressControllerIAMPolicy"
  description = "Policy for ALB Ingress Controller"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "elasticloadbalancing:*",
          "ec2:Describe*",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:CreateSecurityGroupIngress",
          "ec2:CreateTags",
          "acm:*",
          "tag:GetResources",
          "tag:TagResources",
          "iam:PassRole"
        ]
        Resource = "*"
        Effect   = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "alb_ingress_controller_policy_attachment" {
  policy_arn = aws_iam_policy.alb_ingress_controller_policy.arn
  role       = aws_iam_role.alb_ingress_controller.name
}

resource "kubernetes_service_account" "alb_ingress_controller" {
  metadata {
    name      = "alb-ingress-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_ingress_controller.arn
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
