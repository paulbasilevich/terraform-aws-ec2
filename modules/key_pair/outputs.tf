output "ssh_key_name" {
  description = "Name of the dynamically generated ssh key for connection to the EC2 instance"
  value       = var.ssh_key_name
}

output "private_key" {
  description = "Private key string generated for ssh_key_name"
  value       = join(",", values(data.external.private_key.result))
}

output "aws_profile" {
  description = "Name of the AWS profile the EC2 instance is being created in"
  value       = module.provider.profile
}

output "scripts" {
  description = "Centralized location of the shell scripts"
  value       = var.scripts
}

