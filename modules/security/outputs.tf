output "security_group" {
  description = "Security group Id for the EC2 instance being created"
  value       = aws_security_group.plaid.id
}

output "cidr_block" {
  description = "CIDR block evaluated as either <my_host> or <my_cidr> option"
  value       = module.cidr_blk.cbl
}

output "aws_profile" {
  description = "Cascaded relay of the value to the calling module"
  value       = module.cidr_blk.aws_profile
}

output "scripts_home" {
  description = "Centralized location of the shell scripts"
  value       = var.scripts_home
}

output "availability_zone" {
  description = "First zone where the sought instance type is available"
  value       = module.vpc.availability_zone
}

output "public_subnet_id" {
  description = "The ID of the allocated public subnet"
  value       = module.vpc.public_subnet_id
}

output "private_subnet_id" {
  description = "The ID of the allocated private subnet"
  value       = module.vpc.private_subnet_id
}

output "public_subnet_cidr" {
  description = "The CIDR of the allocated public subnet"
  value       = module.vpc.public_subnet_cidr
}

output "private_subnet_cidr" {
  description = "The CIDR of the allocated private subnet"
  value       = module.vpc.private_subnet_cidr
}

output "subnet_config" {
  description = "Subnet specs."
  value       = var.subnet_config
}
output "ec2_instance_type" {
  description = "Instance type returned by the offering"
  value       = module.vpc.ec2_instance_type
}

output "lb_target_group_arn" {
  description = "ARN of the group associated with the load balancer"
  value       = var.ec2_instance_count > 1 ? aws_lb_target_group.plaid[0].arn : null
}

output "lb_dns_name" {
  description = "DNS name of the load balancer"
  value       = var.ec2_instance_count > 1 ? aws_lb.plaid[0].dns_name : null
}
