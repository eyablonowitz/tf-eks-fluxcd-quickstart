output "github_owner" {
  value = var.github_owner
}

output "github_repo_name" {
  value = github_repository.this.name
}

output "github_repo_full_name" {
  value = github_repository.this.full_name
}

output "github_repo_deploy_key" {
  value     = tls_private_key.this.private_key_pem
  sensitive = true
}

output "aws_resource_name" {
  value = var.aws_resource_name
}
