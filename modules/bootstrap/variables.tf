variable "github_owner" {
  type = string
}

variable "github_token" {
  type = string
}

variable "github_repo_name" {
  type = string
}

variable "aws_resource_name" {
  description = "VPC, EKS cluster will use this name."
  type        = string
  default     = "terraform-eks-fluxcd-demo"
}

variable "github_repo_deploy_key_title" {
  type    = string
  default = "fluxcd"
}
