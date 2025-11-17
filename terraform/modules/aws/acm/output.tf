output "acm_arn" {
  value = aws_acm_certificate.cert.arn
}

output "acm_domain_name" {
  value = aws_acm_certificate.cert.domain_name
}
