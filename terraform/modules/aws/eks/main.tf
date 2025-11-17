resource "aws_eks_cluster" "main" {
  name     = var.system_name
  role_arn = aws_iam_role.eks.arn

  vpc_config {
    subnet_ids              = concat(var.private_subnet_ids, var.public_subnet_ids)
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  enabled_cluster_log_types = [
    #"api",
    "audit",
    "authenticator",
    "controllerManager",
  ]

  bootstrap_self_managed_addons = var.auto_mode_is_enabled ? false : true

  compute_config {
    enabled       = var.auto_mode_is_enabled
    node_pools    = var.auto_mode_is_enabled ? ["general-purpose"] : []
    node_role_arn = var.auto_mode_is_enabled ? aws_iam_role.k8s_node.arn : null
  }

  kubernetes_network_config {
    elastic_load_balancing {
      enabled = var.auto_mode_is_enabled
    }
  }

  storage_config {
    block_storage {
      enabled = var.auto_mode_is_enabled
    }
  }

  upgrade_policy {
    support_type = "STANDARD"
  }

  encryption_config {
    provider {
      key_arn = aws_kms_key.eks.arn
    }
    resources = ["secrets"]
  }
  tags = {
    Name = var.system_name
  }
  depends_on = [aws_cloudwatch_log_group.main]
}

resource "aws_eks_addon" "core_dns" {
  count = var.auto_mode_is_enabled ? 0 : 1

  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "coredns"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [aws_eks_cluster.main]
}

resource "aws_eks_addon" "vpc_cni" {
  count = var.auto_mode_is_enabled ? 0 : 1

  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "vpc-cni"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [aws_eks_cluster.main]
}

resource "aws_eks_addon" "kube_proxy" {
  count = var.auto_mode_is_enabled ? 0 : 1

  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "kube-proxy"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [aws_eks_cluster.main]
}

resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key"
  deletion_window_in_days = 7
}

resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/eks/${var.system_name}/cluster"
  retention_in_days = var.log_retention_days
}

resource "aws_iam_role" "eks" {
  name = "${var.system_name}-eks-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })
}

locals {
  eks_policies = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSComputePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy",
  ]

}
resource "aws_iam_role_policy_attachment" "eks_managed_policy" {
  count = length(local.eks_policies)

  role       = aws_iam_role.eks.name
  policy_arn = local.eks_policies[count.index]
}

resource "aws_eks_node_group" "ec2_nodes" {
  count = var.auto_mode_is_enabled ? 0 : 1

  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "ec2-node-group"
  node_role_arn   = aws_iam_role.k8s_node.arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = ["t3.small"]
  capacity_type   = "SPOT"
  scaling_config {
    desired_size = var.min_node_count
    max_size     = var.max_node_count
    min_size     = var.min_node_count
  }
  depends_on = [aws_eks_cluster.main]
}

resource "aws_iam_role" "k8s_node" {
  name = "${var.system_name}-eks-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

locals {
  k8s_node_policies = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodeMinimalPolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ]
}

resource "aws_iam_role_policy_attachment" "k8s_node" {
  count      = length(local.k8s_node_policies)
  policy_arn = local.k8s_node_policies[count.index]
  role       = aws_iam_role.k8s_node.name
}

resource "aws_iam_policy" "s3_access" {
  name        = "${var.system_name}-s3-access"
  description = "Allow access to S3 bucket"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:List*",
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.k8s_node.name
  policy_arn = aws_iam_policy.s3_access.arn
}



resource "aws_eks_access_entry" "current_role" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.id}:role/aws-reserved/sso.amazonaws.com/ap-northeast-1/${split("/", data.aws_caller_identity.current.arn)[1]}"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "current_role" {
  cluster_name  = aws_eks_cluster.main.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.id}:role/aws-reserved/sso.amazonaws.com/ap-northeast-1/${split("/", data.aws_caller_identity.current.arn)[1]}"

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_policy_association" "current_role_cluster_admin" {
  cluster_name  = aws_eks_cluster.main.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.id}:role/aws-reserved/sso.amazonaws.com/ap-northeast-1/${split("/", data.aws_caller_identity.current.arn)[1]}"

  access_scope {
    type = "cluster"
  }
}

data "tls_certificate" "eks_oidc_provider" {
  url = aws_eks_cluster.main.identity[0].oidc.0.issuer
}

resource "aws_iam_openid_connect_provider" "eks_oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc_provider.certificates.0.sha1_fingerprint]
  url             = data.tls_certificate.eks_oidc_provider.url
}

data "aws_caller_identity" "current" {}
