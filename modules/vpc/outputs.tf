output "vpc_id" {
  description = "ID of the custom VPC"
  value       = aws_vpc.smirk.id
}

output "vpc_cidr" {
  description = "CIDR block allocated for the custom vpc"
  value       = aws_vpc.smirk.cidr_block
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
  value       = aws_internet_gateway.smirk.id
}

output "ngw_id" {
  description = "The ID of NAT gateway"
  value       = aws_nat_gateway.smirk[*].id
}

output "ngw_eip" {
  description = "The elastic IP assigned to NAT gateway"
  value       = aws_eip.smirk[*].public_ip
}

output "ec2_instance_type" {
  description = "Instance type returned by the offering"
  value       = data.aws_ec2_instance_type_offerings.av_zone.instance_types[0]
}

