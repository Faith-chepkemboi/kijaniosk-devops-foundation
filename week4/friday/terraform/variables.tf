variable "name_prefix" {
  description = "Prefix for every VM name, giving names like kijanikiosk-api"
  type        = string
  default     = "kijanikiosk"
}

variable "image" {
  description = "Ubuntu release the VMs are launched from"
  type        = string
  default     = "22.04"
}

variable "ssh_public_key_path" {
  description = "Path to the public key injected into each VM"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "ssh_private_key_path" {
  description = "Path to the matching private key, used to build the SSH commands in the outputs"
  type        = string
  default     = "~/.ssh/id_ed25519"
}

variable "ssh_user" {
  description = "Default login user on the Multipass Ubuntu images"
  type        = string
  default     = "ubuntu"
}

variable "servers" {
  description = "The servers to create, keyed by role"
  type = map(object({
    cpus   = number
    memory = string
    disk   = string
  }))
  default = {
    api = {
      cpus   = 1
      memory = "1GiB"
      disk   = "8GiB"
    }
    payments = {
      cpus   = 1
      memory = "1GiB"
      disk   = "8GiB"
    }
    logs = {
      cpus   = 1
      memory = "1GiB"
      disk   = "8GiB"
    }
  }
}
