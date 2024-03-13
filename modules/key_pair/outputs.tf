output "ssh_key_name" {
  description = "Name of the dynamically generated ssh key for connection to the EC2 instance"
  value       = local.ssh_key_name
}

output "source" {
  description = "Path to this location"
  value = path.module
}
