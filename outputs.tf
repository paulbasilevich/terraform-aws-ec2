output "_" {
  description = "Shell command to connect to the target host"
  value       = module.ec2_inst._
}

output "public_ip" {
  description = "Public IP address of the just-created EC2 instance"
  value       = module.ec2_inst.public_ip
}

output "private_ip" {
  description = "Private IP address of the just-created EC2 instance"
  value       = module.ec2_inst.private_ip
}

output "ec2_instance_type" {
  description = "Type of the just-created EC2 instance"
  value       = module.ec2_inst.ec2_instance_type
}

output "ssh_key_name" {
  description = "Name of the created key pair for ssh access to the instance"
  value       = module.ec2_inst.ssh_key_name
}

output "aws_profile" {
  description = "Name of the AWS profile where the EC2 instance is deployed"
  value       = module.ec2_inst.aws_profile
}

output "time" {
  description = "Time formatted and adjusted to PST/PDT"
  value       = module.ec2_inst.time
}

output "ami_name" {
  description = "Name of the AMI retrieved for the current region by AMI name pattern"
  value       = module.ec2_inst.ami_name
}

output "cidr_block" {
  description = "CIDR block evaluated as either <my_host> or <my_cidr> option"
  value       = module.ec2_inst.cidr_block
}

output "aws_secret_name" {
  description = "Name of the AWS secret"
  value       = module.ec2_inst.aws_secret_name
}

output "scripts_home" {
  description = "Centralized location of the shell scripts"
  value       = module.ec2_inst.scripts_home
}

