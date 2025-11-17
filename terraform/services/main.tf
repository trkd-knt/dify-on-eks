
module "aws" {
  source = "../modules/aws"

  system_name = var.system_name
  specs       = var.spec_preset == "production" ? local.specs.production : var.spec_preset == "development" ? local.specs.development : local.specs.custom
  domains     = local.domains
}

module "k8s" {
  source = "../modules/k8s"

  system_name = var.system_name
  specs       = var.spec_preset == "production" ? local.specs.production : var.spec_preset == "development" ? local.specs.development : local.specs.custom

  domains = local.domains

  network_configs     = module.aws.network_configs
  eks_cluster_configs = module.aws.eks_cluster_configs
  db_configs          = module.aws.db_configs
  s3_bucket_name      = module.aws.s3_bucket_name

  depends_on = [module.aws]
}
