##############
# Connection # 
##############

variable "target_machine" {
  type        = string
  description = "Proxmox API endpoint, e.g. https://192.168.0.10:8006/"
}

variable "api_token" {
  type        = string
  description = "Proxmox API token for the target machine"
  sensitive   = true
}

variable "insecure_tls" {
  type        = bool
  description = "Skip TLS verification (self-signed Proxmox certificate)"
  default     = true
}

variable "node_name" {
  type        = string
  description = "Name of the Proxmox node to deploy to"
}

###############
# Environment #
###############

variable "clone_target" {
  type        = number
  description = "VM ID of the cloud-init template to clone, e.g. 9000"
}

variable "datastore_id" {
  type        = string
  description = "Datastore for VM disks and cloud-init drives"
  default     = "local-lvm"
}

variable "bridge" {
  type        = string
  description = "Network bridge for VM NICs"
  default     = "vmbr0"
}

variable "inventory_path" {
  type        = string
  description = "Path (relative to this directory) for the generated Ansible inventory"
  default     = "generated/terraform_inventory.ini"
}

variable "ansible_public_key" {
  type        = string
  description = "SSH public key installed for the ansible user"

  validation {
    condition     = can(regex("^(ssh-ed25519|ssh-rsa|ecdsa-sha2-nistp[0-9]+) AAAA", var.ansible_public_key))
    error_message = "ansible_public_key must be a valid OpenSSH public key."
  }
}

#######
# VMs #
#######

variable "vms" {
  type = map(object({
    vm_id   = number
    name    = string
    profile = string
  }))
  description = "VMs to create, keyed by a short logical name"

  validation {
    condition     = alltrue([for v in values(var.vms) : v.vm_id >= 100])
    error_message = "vm_id must be 100 or higher (Proxmox reserves lower IDs)."
  }

  validation {
    condition     = length(distinct([for v in values(var.vms) : v.vm_id])) == length(var.vms)
    error_message = "Each VM must have a unique vm_id."
  }

  validation {
    condition     = length(distinct([for v in values(var.vms) : v.name])) == length(var.vms)
    error_message = "Each VM must have a unique name."
  }

  validation {
    condition     = alltrue([for v in values(var.vms) : can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?$", v.name))])
    error_message = "VM names must be valid lowercase hostnames (letters, digits, hyphens)."
  }

  validation {
    condition     = alltrue([for v in values(var.vms) : contains(["small", "medium", "large"], v.profile)])
    error_message = "Each VM's profile must be one of: small, medium, large."
  }
}