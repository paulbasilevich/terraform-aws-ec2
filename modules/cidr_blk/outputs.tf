output "now" {
  description = "Time formatted and adjusted to PST/PDT"
  value       = local.time
}

output "cbl" {
  description = "CIDR block evaluated as either <my_host> or <my_cidr> option"
  value       = join(", ", local.cidr_blocks)
}

output "cidr_blocks" {
  description = "White list of CIDR block supplied to the security group"
  value       = local.cidr_blocks
}

output "aws_profile" {
  description = "Declared AWS profile used for this deployment"
  value       = module.provider.profile
}

output "plaid_client_id" {
  description = "Cascaded relay of the value to calling modules"
  value       = module.secr_mgr.plaid_client_id
}

output "plaid_secret" {
  description = "Cascaded relay of the value to calling modules"
  value       = module.secr_mgr.plaid_secret
}

output "aws_secret_name" {
  description = "Name of the AWS secret"
  value       = module.secr_mgr.aws_secret_name
}

