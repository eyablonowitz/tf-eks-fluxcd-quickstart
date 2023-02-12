terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.53"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.8"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }
    flux = {
      source = "fluxcd/flux"
      version = ">= 0.23.0"
    }
  }
}

data "terraform_remote_state" "bootstrap" {
  backend = "local"
  config = {
    path = "${path.module}/modules/bootstrap/terraform.tfstate"
  }
}
