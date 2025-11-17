module "addons" {
  source = "./addons"

  vpc_id              = var.network_configs.vpc_id
  eks_cluster_configs = var.eks_cluster_configs

  auto_mode_is_enabled    = var.specs.eks.auto_mode_is_enabled
  s3_mount_ops_is_enabled = var.specs.eks.s3_mount_ops_is_enabled

}

module "dify" {
  source              = "./dify"

  eks_cluster_configs = var.eks_cluster_configs
  auto_mode_is_enabled = var.specs.eks.auto_mode_is_enabled

  s3_bucket_name      = var.s3_bucket_name
  secrets = {
    name = "db-credentials"
    values = {
      "db_password"       = var.db_configs.db_password
      "db_username"       = var.db_configs.db_username
      "db_endpoint"       = var.db_configs.db_endpoint
      "db_port"           = var.db_configs.db_port
      "db_name"           = var.db_configs.db_name
      "redis_endpoint"    = var.db_configs.redis_endpoint
      "redis_port"        = var.db_configs.redis_port
      "celery_broker_url" = "redis://${var.db_configs.redis_endpoint}:${var.db_configs.redis_port}/1"
      "plugin_db_name"    = "dify_plugin"
    }
  }
  vpc_id = var.network_configs.vpc_id

  domains = var.domains
}
