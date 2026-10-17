terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~>0.11"
    }
    local = {
      source = "hashicorp/local"
    }
  }
}

provider "proxmox" {
  endpoint  = var.target_machine
  api_token = var.api_token
  insecure  = true

}