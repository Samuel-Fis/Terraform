terraform {
  required_version = ">= 1.7"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.11" # tighten to the version in .terraform.lock.hcl
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

provider "proxmox" {
  endpoint  = var.target_machine
  api_token = var.api_token
  insecure  = var.insecure_tls
}