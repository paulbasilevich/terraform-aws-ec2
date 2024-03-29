output "ssh_key_name" {
  description = "Name of the dynamically generated ssh key for connection to the EC2 instance"
  value       = local.ssh_key_name
}

output "source" {
  description = "Path to this location"
  value = path.module
}

output "lan_host_name" {
  value = var.lan_host_name
}

output "sup" {
  description = "SSH connection string to a host on LAN where the current VM is running"
  value       = join(",", values(data.external.sup.result))
}
