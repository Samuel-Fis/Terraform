locals {
  vm_profiles = {
    small = {
      cores  = 1
      memory = 1024
      disk   = 4
    }

    medium = {
      cores  = 2
      memory = 2048
      disk   = 8
    }

    large = {
      cores  = 4
      memory = 4096
      disk   = 16
    }
  }
}