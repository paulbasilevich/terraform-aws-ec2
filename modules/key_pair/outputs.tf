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

output "scripts_home" {
  description = "Centralized location of the shell scripts"
  value       = var.scripts_home
}

output "plaid_client_id" {
  description = "The value of PLAID_CLIENT_ID variable"
  value       = module.secr_mgr.plaid_client_id
  sensitive   = true
}

output "plaid_secret" {
  description = "The value of PLAID_SECRET variable"
  value       = module.secr_mgr.plaid_secret
  sensitive   = true
}

output "aws_secret_name" {
  description = "Name of the AWS secret"
  value       = module.secr_mgr.aws_secret_name
}

