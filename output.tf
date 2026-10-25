# Map of VM name -> IP address (needs the QEMU guest agent).
# [1][0] = first IP on the first real NIC ([0] is loopback).
locals {
  vm_ips = {
    for _, vm in proxmox_virtual_environment_vm.vm :
    vm.name => try(vm.ipv4_addresses[1][0], null)
  }

  # Only VMs that have reported an IP go into the inventory
  inventory_hosts = { for name, ip in local.vm_ips : name => ip if ip != null }
}

# Render the inventory template for Ansible
resource "local_file" "ansible_inventory" {
  filename        = "${path.module}/${var.inventory_path}"
  file_permission = "0644"
  content         = templatefile("${path.module}/inventory.tftpl", { vms = local.inventory_hosts })
}

output "vm_ips" {
  description = "VM name to IPv4 address"
  value       = local.vm_ips
}

# Warns (does not fail) if a VM has no IP yet
check "vm_ips_resolved" {
  assert {
    condition     = alltrue([for ip in values(local.vm_ips) : ip != null])
    error_message = "A VM has no IP yet. Check the QEMU guest agent is running in the template."
  }
}