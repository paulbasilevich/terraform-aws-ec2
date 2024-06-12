output "plaid_client_id" {
  description = "The value of PLAID_CLIENT_ID variable"
  value       = local.plaid_client_id
  sensitive   = true
}

output "plaid_secret" {
  description = "The value of PLAID_SECRET variable"
  value       = local.plaid_secret
  sensitive   = true
}

output "aws_secret_name" {
  description = "Name of the AWS secret"
  value       = var.aws_secret_name
}

output "scripts_home" {
  description = "Centralized location of the shell scripts"
  value       = var.scripts_home
}

output "env_status" {
  description = "Indicates whether the credentials are available"
  value       = local.env_status
}
