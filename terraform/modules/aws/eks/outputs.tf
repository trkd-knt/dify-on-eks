output "k8s_cluster_name" {
  value = aws_eks_cluster.main.name
}

output "k8s_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "cluster_ca_certificate" {
  value = base64decode(aws_eks_cluster.main.certificate_authority.0.data)
}

output "issuer_url" {
  value = aws_eks_cluster.main.identity.0.oidc.0.issuer
}

output "eks_version" {
  value = aws_eks_cluster.main.version
}
output "eks_oidc_provider" {
  value = {
    url              = data.tls_certificate.eks_oidc_provider.url
    sha1_fingerprint = data.tls_certificate.eks_oidc_provider.certificates.0.sha1_fingerprint
  }
}
