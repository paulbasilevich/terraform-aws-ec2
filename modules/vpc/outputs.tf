output "deployed_at" {
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

output "vpc_id" {
  description = "ID of the custom VPC"
  value       = aws_vpc.pilot.id
}

output "vpc_cidr" {
  description = "CIDR block allocated for the custom vpc"
  value       = aws_vpc.pilot.cidr_block
}

output "availability_zone" {
  description = "First zone where the sought instance type is available"
  value       = data.aws_ec2_instance_type_offerings.av_zone.locations[*]
}

output "subnets" {
  description = "Summarized public and private subnets specs"
  value       = <<-EOT

    ${local.public_subnet_name}  - ${local.public_subnet_id}  - ${local.public_subnet_cidr}
    ${local.private_subnet_name} - ${local.private_subnet_id}  - ${local.private_subnet_cidr}
  EOT
}

output "public_subnet_id" {
  description = "The ID of the allocated public subnet"
  value       = local.public_subnet_id
}

output "private_subnet_id" {
  description = "The ID of the allocated private subnet"
  value       = local.private_subnet_id
}

output "public_subnet_cidr" {
  description = "The CIDR of the allocated public subnet"
  value       = local.public_subnet_cidr
}

output "private_subnet_cidr" {
  description = "The CIDR of the allocated private subnet"
  value       = local.private_subnet_cidr
}

output "route_tables" {
  description = "Summarized public and private route_table IDs"
  value       = <<-EOT
    ${local.public_route_table_name}  - ${local.public_route_table_id}
    ${local.private_route_table_name} - ${local.private_route_table_id}
  EOT
}

output "public_route_table_id" {
  description = "The ID of the allocated public route_table"
  value       = local.public_route_table_id
}

output "private_route_table_id" {
  description = "The ID of the allocated private route_table"
  value       = local.private_route_table_id
}

output "igw_id" {
  description = "The ID of the internet gateway"
  value       = aws_internet_gateway.pilot.id
}

output "ngw_id" {
  description = "The ID of NAT gateway"
  value       = aws_nat_gateway.pilot[*].id
}

output "ngw_eip" {
  description = "The elastic IP assigned to NAT gateway"
  value       = aws_eip.pilot[*].public_ip
}

output "ec2_instance_type" {
  description = "Instance type returned by the offering"
  value       = data.aws_ec2_instance_type_offerings.av_zone.instance_types[0]
}

output "common_tags" {
  description = "Tags generated from to be applied to all resources"
  value       = local.common_tags
}

output "instance_config" {
  description = "For public and private subnets - SubnetId and private IP"
  value       = local.instance_config
}

output "ec2_instance_count" {
  description = "If 1 - create only public subnet; 2 - add private subnet"
  value       = local.ec2_instance_count
}

output "aws_profile" {
  description = "Declared AWS profile used for this deployment"
  value       = module.provider.profile
}

output "scripts_home" {
  description = "Centralized location of the shell scripts"
  value       = var.scripts_home
}

output "subnet_suffix" {
  description = "Label subnets as public and private, if the web host runs in private"
  value       = local.subnet_suffix
}

output "common_name_root" {
  description = "Family name for all deployed resources"
  value       = local.common_name_root
}
