locals {
  eks_cluster_version = "1.24"
  github_owner           = data.terraform_remote_state.bootstrap.outputs.github_owner
  github_repo_deploy_key = data.terraform_remote_state.bootstrap.outputs.github_repo_deploy_key
  github_repo_name       = data.terraform_remote_state.bootstrap.outputs.github_repo_name
  name                   = data.terraform_remote_state.bootstrap.outputs.aws_resource_name

  tags = {
    Owner    = local.name
  }
}
