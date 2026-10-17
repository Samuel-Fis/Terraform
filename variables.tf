#######################################################################
# defined based on host chosen when running terraform apply -var-file #
#######################################################################

variable "target_machine" {
  type        = string
  description = "the web adress for the target machine. e.g. https://192.168.0.0:8006"
}

variable "api_token" {
  type        = string
  description = "api token for connecting to previously specified target machine"
  sensitive   = true
}

variable "node_name" {
  type        = string
  description = "name of the proxmox node you are connecting to"
}

variable "clone_target" {
  type        = number
  description = "vmid of the clone template, e.g 9000"
}

##################################################################
#needs to be defined when applying unless default option required#
##################################################################

variable "cores" {
  type        = number
  description = "number of cores assigned to vm"
  default     = 1
}

variable "memory" {
  type        = number
  description = "amount of memory assigned to VM"
  default     = 512
}

variable "disk_size" {
  type        = number
  description = "amount of disk space assigned to a vm"
  default     = 8096
}

variable "vm_name_prefix" {
  type        = string
  description = "Prefix used for VM names"
  default     = "tf-vm"
}

########################################################
# vm_profiles definition, referenced in vm_profiles.tf #
########################################################

variable "vms" {
  type = map(object({
    vm_id   = number
    name    = string
    profile = string
  }))
}

###########################
# Ansible public key Creds#
###########################

variable "ansible_public_key" {
  type       = string
  description = "Public key for the ansible user, same one used on the existing hosts"
  senstive = true
}
