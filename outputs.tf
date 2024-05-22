# output "now" {
#   description = "Time formatted and adjusted to PST/PDT"
#   value       = local.time
# }

output "_" {
  description = "Shell command to connect to the target host"
  value       = "Connect to the deployed instance: >>> ssh ${module.ec2_inst.ssh_key_name} <<<  "
}

output "ami_name" {
  description = "Name of the AMI retrieved for the current region by AMI name pattern"
  value       = module.ec2_inst.ami_name
}

output "ec2_instance_type" {
  value = module.ec2_inst.ec2_instance_type
}

output "aws_profile" {
  value = module.ec2_inst.aws_profile
}

# output "public_ip" {
#   value = module.ec2_inst.public_ip
# }

