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

output "scripts_home" {
  description = "Centralized location of the shell scripts"
  value       = var.scripts_home
}
