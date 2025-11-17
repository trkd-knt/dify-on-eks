resource "aws_s3_bucket" "main" {
  bucket = "${var.system_name}-${data.aws_caller_identity.current.account_id}-data"
}

data "aws_caller_identity" "current" {}
