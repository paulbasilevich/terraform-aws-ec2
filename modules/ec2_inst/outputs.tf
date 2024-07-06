output "_" {
  description = "Shell command to connect to the target host"
  value       = "Connect to the deployed instance: >>> ssh ${module.key_pair.ssh_key_name} <<<  "
}

# output "IP" {
#   description = "Sample zipmap: instance-id -> public_ip, private_ip"
#   value = zipmap(
#     [aws_instance.tf["tf"].id],
#     [[aws_instance.tf["tf"].public_ip, aws_instance.tf["tf"].private_ip]]
# 
#   )
# }
# 

output "public_ip" {
  description = "Public IP address of the just-created EC2 instance"
  value       = join(", ", aws_instance.plaid[*].public_ip)
}

output "private_ip" {
  description = "Private IP address of the just-created EC2 instance"
  value       = join(", ", aws_instance.plaid[*].private_ip)
}

output "ec2_instance_type" {
  description = "Type of the just-created EC2 instance"
  value       = join(", ", aws_instance.plaid[*].instance_type)
}

output "ssh_key_name" {
  description = "Name of the created key pair for ssh access to the instance"
  value       = module.key_pair.ssh_key_name
}

output "aws_profile" {
  description = "Name of the AWS profile where the EC2 instance is deployed"
  value       = module.security.aws_profile
}

output "time" {
  description = "Time formatted and adjusted to PST/PDT"
  value       = local.time
}

output "ami_name" {
  description = "Name of the AMI retrieved for the current region by AMI name pattern"
  value       = module.ami_data.ami_name
}

output "cidr_block" {
  description = "CIDR block evaluated as either <my_host> or <my_cidr> option"
  value       = module.security.cidr_block
}

output "aws_secret_name" {
  description = "Name of the AWS secret"
  value       = module.key_pair.aws_secret_name
}

output "scripts_home" {
  description = "Centralized location of the shell scripts"
  value       = var.scripts_home
}

