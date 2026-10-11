resource "proxmox_virtual_environment_vm" "vm" {
  for_each = var.vms

  name      = each.value.name
  vm_id     = each.value.vm_id
  node_name = var.node_name

  clone {
    vm_id = var.clone_target #target template for cloning on host
    full  = true
  }

  cpu {
    cores = local.vm_profiles[each.value.profile].cores
  }

  memory {
    dedicated = local.vm_profiles[each.value.profile].memory
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = local.vm_profiles[each.value.profile].disk
  }

  network_device {
    bridge = "vmbr0"

  }
  #############################################################
  # this is for Qemu agent so proxmox host can talk to the VM #
  #############################################################

  agent {
    enabled = true
  }

  #########################################
  # sets DHCP to enabled so vm gets an IP #
  #########################################

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }
}