resource "proxmox_virtual_environment_vm" "vm" {
  for_each = var.vms

  name        = each.value.name
  vm_id       = each.value.vm_id
  node_name   = var.node_name
  description = "Managed by Terraform"
  tags        = ["terraform", each.value.profile]

  # Full clone of the cloud-init template
  clone {
    vm_id = var.clone_target
    full  = true
  }

  cpu {
    cores = local.vm_profiles[each.value.profile].cores
  }

  memory {
    dedicated = local.vm_profiles[each.value.profile].memory
  }

  disk {
    datastore_id = var.datastore_id
    interface    = "scsi0"
    size         = local.vm_profiles[each.value.profile].disk
  }

  network_device {
    bridge = var.bridge
  }

  # QEMU guest agent, so Proxmox (and Terraform) can read the VM's IP
  agent {
    enabled = true
  }

  # Cloud-init: ansible user + DHCP
  initialization {
    datastore_id = var.datastore_id

    user_account {
      username = "ansible"
      keys     = [var.ansible_public_key]
    }

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }
}