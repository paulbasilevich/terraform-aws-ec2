output "tf_sg" {
  description = "Security group Id for the EC2 instance being created"
  value       = aws_security_group.tf_sg.id
}

output "cidr_block" {
  description = "CIDR block evaluated as either <my_host> or <my_cidr> option"
  value       = module.cidr_blk.cbl
}

output "aws_profile" {
  description = "Cascaded relay of the value to the calling module"
  value       = module.cidr_blk.aws_profile
}

output "plaid_client_id" {
  description = "Cascaded relay of the value to the calling module"
  value       = module.cidr_blk.plaid_client_id
}

output "plaid_secret" {
  description = "Cascaded relay of the value to the calling module"
  value       = module.cidr_blk.plaid_secret
}

output "aws_secret_name" {
  description = "Name of the AWS secret"
  value       = module.cidr_blk.aws_secret_name
}

