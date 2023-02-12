provider "aws" {
  region = var.region
}

provider "flux" {
  host                   = module.eks_fluxcd.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_fluxcd.cluster_certificate_authority_data)
  token                  = module.eks_fluxcd.eks_cluster_auth_token
}

provider "kubernetes" {
  host                   = module.eks_fluxcd.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_fluxcd.cluster_certificate_authority_data)
  token                  = module.eks_fluxcd.eks_cluster_auth_token
}

provider "helm" {
  kubernetes {
    host                   = module.eks_fluxcd.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_fluxcd.cluster_certificate_authority_data)
    token                  = module.eks_fluxcd.eks_cluster_auth_token
  }
}
