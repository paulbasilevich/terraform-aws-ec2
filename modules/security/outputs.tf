output "security_group" {
  description = "Security group Id for the EC2 instance being created"
  value       = aws_security_group.pilot.id
}

output "cidr_block" {
  description = "CIDR block evaluated as either <my_host> or <my_cidr> option"
  value       = module.vpc.cbl
}

output "aws_profile" {
  description = "Cascaded relay of the value to the calling module"
  value       = module.vpc.aws_profile
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
  value       = module.vpc.ec2_instance_count > 1 ? aws_lb_target_group.pilot[0].arn : null
}

output "lb_dns_name" {
  description = "DNS name of the load balancer"
  value       = module.vpc.ec2_instance_count > 1 ? aws_lb.pilot[0].dns_name : null
}

output "common_tags" {
  description = "Tags generated from to be applied to all resources"
  value       = module.vpc.common_tags
}

output "instance_config" {
  description = "For public and private subnets - SubnetId and private IP"
  value       = module.vpc.instance_config
}

output "ec2_instance_count" {
  description = "If 1 - create only public subnet; 2 - add private subnet"
  value       = module.vpc.ec2_instance_count
}

output "subnet_suffix" {
  description = "Label subnets as public and private, if the web host runs in private"
  value       = module.vpc.subnet_suffix
}

output "common_name_root" {
  description = "Family name for all deployed resources"
  value       = module.vpc.common_name_root
}

output "deployed_at" {
  description = "Current time stamp"
  value       = module.vpc.deployed_at
}
