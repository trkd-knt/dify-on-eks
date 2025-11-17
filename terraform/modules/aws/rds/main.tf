resource "aws_rds_cluster_parameter_group" "main" {
  name        = "${var.system_name}-cluster"
  family      = "aurora-postgresql16"
  description = "RDS Cluster Parameter Group for ${var.system_name}"

  # parameter {
  #   name  = "log_statement"
  #   value = "all"
  #   apply_method = "pending-reboot"
  # }
# 
  # parameter {
  #   name  = "log_min_duration_statement"
  #   value = "1000"
  #   apply_method = "immediate"
  # }
# 
  # parameter {
  #   name  = "idle_in_transaction_session_timeout"
  #   value = "60000"
  #   apply_method = "immediate"
  # }
# 
  # parameter {
  #   name  = "work_mem"
  #   value = "4MB"
  #   apply_method = "immediate"
  # }
# 
  # parameter {
  #   name  = "max_connections"
  #   value = "500"
  #   apply_method = "pending-reboot"
  # }
# 
  # parameter {
  #   name  = "default_transaction_isolation"
  #   value = "read committed"
  #   apply_method = "immediate"
  # }
# 
  # parameter {
  #   name  = "statement_timeout"
  #   value = "60000"
  #   apply_method = "immediate"
  # }
# 
  # parameter {
  #   name  = "log_connections"
  #   value = "1"
  #   apply_method = "immediate"
  # }
# 
  # parameter {
  #   name  = "log_disconnections"
  #   value = "1"
  #   apply_method = "immediate"
  # }
# 
  # parameter {
  #   name  = "log_duration"
  #   value = "1"
  #   apply_method = "immediate"
  # }
# 
  # parameter {
  #   name  = "log_checkpoints"
  #   value = "1"
  #   apply_method = "immediate"
  # }
# 
  # parameter {
  #   name  = "log_temp_files"
  #   value = "1024"
  #   apply_method = "immediate"
  # }
# 
  # parameter {
  #   name  = "log_lock_waits"
  #   value = "1"
  #   apply_method = "immediate"
  # }
# 
  # parameter {
  #   name  = "log_autovacuum_min_duration"
  #   value = "1000"
  #   apply_method = "immediate"
  # }

  # parameter {
  #   name  = "shared_buffers"
  #   value = "128MB"
  #   apply_method = "pending-reboot"
  # }
# 
  # parameter {
  #   name  = "effective_cache_size"
  #   value = "512MB"
  #   apply_method = "pending-reboot"
  # }
# 
  # parameter {
  #   name  = "maintenance_work_mem"
  #   value = "64MB"
  #   apply_method = "immediate"
  # }
}

resource "aws_db_subnet_group" "private" {
  name       = "${var.system_name}-private"
  subnet_ids = var.private_subnet_ids
}

resource "aws_security_group" "rds" {
  name   = "${var.system_name}-db"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }
}

resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "aws_ssm_parameter" "db_password" {
  name = "/${var.system_name}/db-password"
  type = "SecureString"
  value = random_password.db_password.result
}

data "aws_ssm_parameter" "db_password" {
  name = "/${var.system_name}/db-password"
  with_decryption = true
  depends_on = [ aws_ssm_parameter.db_password ]
}

resource "random_id" "snapshot_id" {
  byte_length = 4
}

resource "aws_rds_cluster" "main" {
  cluster_identifier = var.system_name
  engine             = "aurora-postgresql"

  engine_mode                     = "provisioned"
  availability_zones              = data.aws_availability_zones.available.names
  engine_version                  = "16"
  db_subnet_group_name            = aws_db_subnet_group.private.name
  database_name                   = "dify"
  master_username                 = "dify"
  master_password                 = data.aws_ssm_parameter.db_password.value
  backtrack_window                = 0
  backup_retention_period         = var.backup_retention_period
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.main.name
  port                            = 5432
  skip_final_snapshot             = false
  storage_encrypted               = true
  vpc_security_group_ids          = [aws_security_group.rds.id]

  serverlessv2_scaling_configuration {
    min_capacity = var.min_capacity
    max_capacity = var.max_capacity
  }

  deletion_protection       = false
  apply_immediately         = true
  final_snapshot_identifier = "final-snapshot-${var.system_name}-${random_id.snapshot_id.hex}"

  lifecycle {
    ignore_changes = [
      master_password,
      availability_zones
    ]
  }
}

resource "aws_db_parameter_group" "main" {
  name   = "${var.system_name}-instance"
  family = "aurora-postgresql16"
}

resource "aws_rds_cluster_instance" "main" {
  count = var.rds_instance_count > length(data.aws_availability_zones.available.names) ? length(data.aws_availability_zones.available.names) : var.rds_instance_count

  availability_zone  = element(data.aws_availability_zones.available.names, count.index)
  cluster_identifier = aws_rds_cluster.main.id

  identifier     = "db-instance-${format("%02d", count.index + 1)}"
  engine         = aws_rds_cluster.main.engine
  engine_version = aws_rds_cluster.main.engine_version

  instance_class             = "db.serverless"
  db_subnet_group_name       = aws_db_subnet_group.private.name
  db_parameter_group_name    = aws_db_parameter_group.main.name
  publicly_accessible        = false
  auto_minor_version_upgrade = true
}

data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}
