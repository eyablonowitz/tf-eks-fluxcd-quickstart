variable "eks_cluster_name" {
  type = string
}

variable "eks_cluster_version" {
  type    = string
}

variable "eks_control_plane_subnet_ids" {
  type = list(string)
}

variable "eks_subnets_ids" {
  type = list(string)
}

variable "eks_vpc_id" {
  type = string
}

variable "github_owner" {
  type = string
}

variable "github_repo_deploy_key" {
  type = string
}

variable "github_repo_name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
