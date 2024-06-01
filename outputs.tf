output "_" {
  description = "Shell command to connect to the target host"
  value       = module.ec2_inst._
}

output "aws_profile" {
  description = "Name of the AWS profile the EC2 instance is being created in"
  value       = module.ec2_inst.aws_profile
}

output "ami_name" {
  description = "Name of the AMI retrieved for the current region by AMI name pattern"
  value       = module.ec2_inst.ami_name
}

output "cidr_block" {
  description = "CIDR block evaluated as either <my_host> or <my_cidr> option"
  value       = module.ec2_inst.cidr_block
}

output "public_ip" {
  description = "Public IP address of the just-created EC2 instance"
  value       = module.ec2_inst.public_ip
}

output "ec2_instance_type" {
  description = "Type of the just-created EC2 instance"
  value       = module.ec2_inst.ec2_instance_type
}

output "ssh_key_name" {
  description = "Name of the created key pair for ssh access to the instance"
  value       = module.ec2_inst.ssh_key_name
}

