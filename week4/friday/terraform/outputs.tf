output "server_ips" {
  description = "IP address of each server, keyed by role"
  value       = { for role, server in module.servers : role => server.ip }
}

output "ssh_commands" {
  description = "Ready-to-use SSH command for each server"
  value = {
    for role, server in module.servers :
    role => "ssh -i ${var.ssh_private_key_path} ${var.ssh_user}@${server.ip}"
  }
}
