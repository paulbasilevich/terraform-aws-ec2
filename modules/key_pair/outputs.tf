output "ssh_key_name" {
  description = "Name of the dynamically generated ssh key for connection to the EC2 instance"
  value       = var.ssh_key_name
}

output "private_key" {
  description = "Private key string generated for ssh_key_name"
  value       = join(",", values(data.external.private_key.result))
}

output "source" {
  description = "Path to this location"
  value       = path.module
}

output "aws_profile" {
  value = module.provider.profile
}
