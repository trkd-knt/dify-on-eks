module "aws_network" {
  source      = "./vpc"
  system_name = var.system_name
  cidr_block  = try(var.specs.vpc_cidr_block, "10.0.0.0/16")
}

# module "aws_alb" {
#   source = "./alb"
# 
#   system_name        = var.system_name
#   public_subnet_ids = module.aws_network.public_subnet_ids
#   vpc_id            = module.aws_network.vpc_id
#   vpc_cidr_block = module.aws_network.vpc_cidr_block
#   use_custom_domain = try(var.domains.use_custom_domain,false)
#   hosted_zone_name  = try(var.domains.hosted_zone_name,null)
# }

module "aws_acm" {
  source = "./acm"

  hosted_zone_name     = var.domains.hosted_zone_name
}

module "aws_eks" {
  source = "./eks"

  system_name        = var.system_name
  private_subnet_ids = module.aws_network.private_subnet_ids
  public_subnet_ids  = module.aws_network.public_subnet_ids

  auto_mode_is_enabled = try(var.specs.eks.auto_mode_is_enabled, false)
  log_retention_days   = try(var.specs.log_retention_days, 7)
  min_node_count       = try(var.specs.eks.min_node_count, 2)
  max_node_count       = try(var.specs.eks.max_node_count, 5)
}

module "aws_rds" {
  source = "./rds"

  system_name             = var.system_name
  private_subnet_ids      = module.aws_network.private_subnet_ids
  vpc_id                  = module.aws_network.vpc_id
  vpc_cidr_block          = module.aws_network.vpc_cidr_block
  backup_retention_period = try(var.specs.rds.backup_retention_period, 7)
  min_capacity            = try(var.specs.rds.min_capacity, 0)
  max_capacity            = try(var.specs.rds.max_capacity, 1)
  rds_instance_count      = try(var.specs.rds.instance_count, 1)
}

module "aws_redis" {
  source = "./redis"

  system_name             = var.system_name
  private_subnet_ids      = module.aws_network.private_subnet_ids
  vpc_id                  = module.aws_network.vpc_id
  max_storage_gigabytes   = try(var.specs.redis.max_storage_gigabytes, 10)
  daily_snapshot_time     = try(var.specs.redis.daily_snapshot_time, "09:00")
  backup_retention_period = try(var.specs.redis.backup_retention_period, 7)
}

module "aws_s3" {
  source = "./s3"

  system_name = var.system_name
}
