resource "aws_elasticache_serverless_cache" "main" {
  name   = var.system_name
  engine = "valkey"
  cache_usage_limits {
    data_storage {
      maximum = var.max_storage_gigabytes
      unit    = "GB"
    }
    ecpu_per_second {
      maximum = 5000
    }
  }
  daily_snapshot_time      = var.daily_snapshot_time
  kms_key_id               = aws_kms_key.redis.arn
  major_engine_version     = "7"
  snapshot_retention_limit = var.backup_retention_period
  security_group_ids       = [aws_security_group.redis.id]
  subnet_ids               = var.private_subnet_ids
}

resource "aws_kms_key" "redis" {
  description = "Redis Encryption Key"
}

resource "aws_security_group" "redis" {
  name   = "${var.system_name}-redis"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
