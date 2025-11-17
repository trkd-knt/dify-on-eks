output "db_endpoint" {
  value = aws_rds_cluster.main.endpoint
}

output "db_port" {
  value = aws_rds_cluster.main.port
}

output "db_username" {
  value = aws_rds_cluster.main.master_username
}

output "db_password" {
  value = aws_rds_cluster.main.master_password
}

output "db_name" {
  value = aws_rds_cluster.main.database_name
}
