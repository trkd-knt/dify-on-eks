output "s3_bucket_name" {
  value = module.aws_s3.s3_bucket_name
}

output "network_configs" {
  value = {
    vpc_id          = module.aws_network.vpc_id
    vpc_cidr_block  = module.aws_network.vpc_cidr_block
    private_subnets = module.aws_network.private_subnet_ids
    public_subnets  = module.aws_network.public_subnet_ids
    nat_eip         = module.aws_network.nat_eip
  }
}

output "eks_cluster_configs" {
  value = {
    cluster_name           = module.aws_eks.k8s_cluster_name
    eks_version            = module.aws_eks.eks_version
    k8s_endpoint           = module.aws_eks.k8s_endpoint
    cluster_ca_certificate = module.aws_eks.cluster_ca_certificate
    issuer_url             = module.aws_eks.issuer_url
    eks_oidc_provider      = module.aws_eks.eks_oidc_provider
    cert_arn = module.aws_acm.acm_arn
  }
}

output "db_configs" {
  value = {
    db_endpoint    = module.aws_rds.db_endpoint
    db_port        = module.aws_rds.db_port
    db_username    = module.aws_rds.db_username
    db_password    = module.aws_rds.db_password
    db_name        = module.aws_rds.db_name
    redis_endpoint = module.aws_redis.endpoint
    redis_port     = module.aws_redis.port
  }
}
