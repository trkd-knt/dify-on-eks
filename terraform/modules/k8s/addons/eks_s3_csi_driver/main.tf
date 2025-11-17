data "aws_eks_addon_version" "s3_csi" {
  addon_name         = "aws-mountpoint-s3-csi-driver"
  kubernetes_version = var.eks_cluster_configs.eks_version
}

resource "aws_eks_addon" "s3_csi" {
  cluster_name                = var.eks_cluster_configs.cluster_name
  addon_name                  = "aws-mountpoint-s3-csi-driver"
  addon_version               = data.aws_eks_addon_version.s3_csi.version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  service_account_role_arn = aws_iam_role.eks_s3_csi_driver.arn
}

resource "aws_iam_policy" "eks_s3_csi_driver" {
  name = "AmazonS3CSIDriverPolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid" : "MountpointFullObjectAccess",
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:AbortMultipartUpload",
          "s3:DeleteObject"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role" "eks_s3_csi_driver" {
  name = "${var.eks_cluster_configs.cluster_name}-eks-s3-csi-driver-role"

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
            "${trimprefix(var.eks_cluster_configs.eks_oidc_provider.url, "https://")}:sub" = "system:serviceaccount:kube-system:s3-csi-driver-sa"
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

resource "aws_iam_role_policy_attachment" "s3_csi_driver_attachment" {
  role       = aws_iam_role.eks_s3_csi_driver.name
  policy_arn = aws_iam_policy.eks_s3_csi_driver.arn
}

resource "kubernetes_service_account" "s3_csi_driver_sa" {
  metadata {
    name      = "s3-csi-driver-sa"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.eks_s3_csi_driver.arn
    }
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels
    ]
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
