output "cluster_arn" {
  value       = module.eks.cluster_arn
}

output "cluster_certificate_authority_data" {
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  value       = module.eks.cluster_name
}

output "eks_cluster_auth_token" {
  value = data.aws_eks_cluster_auth.this.token
}
