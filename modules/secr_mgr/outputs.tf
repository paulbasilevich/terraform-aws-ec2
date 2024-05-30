# output "env_status" {
#   value = local.env_status
# }

# output "aws_secret_status" {
#   value = local.aws_secret_status
# }

output "plaid_client_id" {
  value     = local.plaid_client_id
  sensitive = true
}

output "plaid_secret" {
  value     = local.plaid_secret
  sensitive = true
}

# output "raw_env_status" {
#   value = local.raw_env_status
# }



