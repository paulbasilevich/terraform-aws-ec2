output "now" {
  description = "Time formatted and adjusted to PST/PDT"
  value       = local.time
}

output "cbl" {
  description = "CIDR block evaluated as either <my_host> or <my_cidr> option"
  value       = join(", ", local.cidr_blocks)
}

output "cidr_blocks" {
  value = local.cidr_blocks
}

output "aws_profile" {
  value = module.provider.profile
}

output "plaid_client_id" {
  value = module.secr_mgr.plaid_client_id
}

output "plaid_secret" {
  value = module.secr_mgr.plaid_secret
}

