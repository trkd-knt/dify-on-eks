output "site_domain" {
  value = var.use_custom_domain ? module.cert.acm_domain_name : aws_lb.dify_alb.dns_name
}

output "target_group_arns" {
  value = {
    "dify-api" = aws_lb_target_group.dify_api.arn
    "dify-web" = aws_lb_target_group.dify_web.arn
    "sg-id" = aws_security_group.dify_alb.id
  }
}
