locals {
  specs = {
    production = {
      cidr_block = "11.0.0.0/8"
      eks = {
        auto_mode_is_enabled    = true
        s3_mount_ops_is_enabled = true
        min_node_count          = 2
        max_node_count          = 5
      }
      rds = {
        backup_retention_period = 30
        min_capacity            = 1
        max_capacity            = 10
        instance_count          = 2
      }
      redis = {
        max_storage_gigabytes   = 10
        daily_snapshot_time     = "09:00"
        backup_retention_period = 30
      }
      log_retention_days = 30
    }

    development = {
      cidr_block = "10.0.0.0/8"
      eks = {
        auto_mode_is_enabled    = true
        s3_mount_ops_is_enabled = true
        min_node_count          = 2
        max_node_count          = 5
      }
      rds = {
        backup_retention_period = 7
        min_capacity            = 0
        max_capacity            = 1
        instance_count          = 1
      }
      redis = {
        max_storage_gigabytes   = 10
        daily_snapshot_time     = "09:00"
        backup_retention_period = 7
      }
      log_retention_days = 7
    }
  }
}

locals {
  domains = {
    hosted_zone_name = "terra.sandbox.dp.tokyu.co.jp"

    console = "admin.dify"
    service = "service.dify"
  }
}
