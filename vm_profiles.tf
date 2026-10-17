locals {
  vm_profiles = {
    small = {
      cores  = 1
      memory = 2048
      disk   = 6
    }

    medium = {
      cores  = 2
      memory = 4096
      disk   = 12
    }

    large = {
      cores  = 4
      memory = 8192
      disk   = 18
    }
  }
}