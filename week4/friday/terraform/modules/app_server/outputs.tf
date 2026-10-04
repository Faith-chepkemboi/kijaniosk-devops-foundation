output "name" {
  description = "Name of the VM"
  value       = data.multipass_instance.this.name
}

output "ip" {
  description = "IPv4 address of the VM, read back from Multipass"
  value       = data.multipass_instance.this.ipv4
}
