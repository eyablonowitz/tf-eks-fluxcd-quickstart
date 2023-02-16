output "region" {
  value = var.region
}

output "eks_cluster_name" {
  value = module.eks_fluxcd.cluster_name
}
