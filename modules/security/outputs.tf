output "tf_sg" {
  description = "Security group Id for the EC2 instance being created"
  value       = aws_security_group.tf_sg.id
}

output "aws_profile" {
  value = module.cidr_blk.aws_profile
}

output "plaid_client_id" {
  value = module.cidr_blk.plaid_client_id
}

output "plaid_secret" {
  value = module.cidr_blk.plaid_secret
}
