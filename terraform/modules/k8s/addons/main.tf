module "alb_ingress_controller" {
  count  = var.auto_mode_is_enabled ? 0 : 1
  source = "./alb_ingress_controller"

  vpc_id              = var.vpc_id
  eks_cluster_configs = var.eks_cluster_configs
}

module "eks_s3_csi_driver" {
  count  = var.s3_mount_ops_is_enabled ? 1 : 0
  source = "./eks_s3_csi_driver"

  eks_cluster_configs = var.eks_cluster_configs
}
