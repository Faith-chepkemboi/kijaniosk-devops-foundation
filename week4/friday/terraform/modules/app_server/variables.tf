variable "name" {
  description = "Name of the Multipass VM"
  type        = string
}

variable "cpus" {
  description = "Number of CPUs for the VM"
  type        = number
}

variable "memory" {
  description = "Memory for the VM, e.g. 1GiB"
  type        = string
}

variable "disk" {
  description = "Disk size for the VM, e.g. 10GiB"
  type        = string
}

variable "image" {
  description = "Ubuntu image to launch, e.g. 22.04"
  type        = string
}

variable "ssh_public_key" {
  description = "Public SSH key injected into the VM through cloud-init"
  type        = string
}
