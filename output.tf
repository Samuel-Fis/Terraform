# Build a map of VM name -> IP address (needs the QEMU guest agent).
# [1][0] = first IP on the first real NIC ([0] is loopback).
locals {
  vm_ips = {
    for k, vm in proxmox_virtual_environment_vm.vm :
    vm.name => vm.ipv4_addresses[1][0]
  }
}

# Fill inventory.tftpl with the IP map and write it to ~/Ansible/terraform_inventory.ini
resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../Ansible/terraform_inventory.ini"
  content  = templatefile("${path.module}/inventory.tftpl", { vms = local.vm_ips })
}

# Print the VM IPs at the end of terraform apply
output "vm_ips" {
  value = local.vm_ips
}
