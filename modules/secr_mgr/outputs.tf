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


