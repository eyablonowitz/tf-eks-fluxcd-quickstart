module "eks_fluxcd" {
  source = "./modules/eks-fluxcd/"

  eks_cluster_name = local.name
  eks_cluster_version = local.eks_cluster_version
  eks_control_plane_subnet_ids = module.vpc.intra_subnets
  eks_subnets_ids = module.vpc.private_subnets
  eks_vpc_id = module.vpc.vpc_id

  github_owner = local.github_owner
  github_repo_deploy_key = local.github_repo_deploy_key
  github_repo_name = local.github_repo_name
}
