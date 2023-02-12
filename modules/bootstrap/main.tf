provider "github" {
  owner = var.github_owner
  token = var.github_token
}

resource "tls_private_key" "this" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "github_repository" "this" {
  name       = var.github_repo_name
  visibility = "public"
  auto_init  = true
}

resource "github_repository_file" "fluxcd_manifests" {
  for_each = fileset("${path.module}/../../fluxcd-manifests", "**/*.yaml")

  repository          = github_repository.this.name
  branch              = "main"
  file                = "clusters/${var.aws_resource_name}/${each.value}"
  content             = file("${path.module}/../../fluxcd-manifests/${each.value}")
  commit_message      = "Managed by Terraform"
  commit_author       = "Terraform User"
  commit_email        = "terraform@example.com"
  overwrite_on_create = false
}

resource "github_repository_deploy_key" "this" {
  title      = var.github_repo_deploy_key_title
  repository = github_repository.this.name
  key        = tls_private_key.this.public_key_openssh
  read_only  = false
}
