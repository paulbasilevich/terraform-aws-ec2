output "_" {
  description = "Shell command to connect to the target host"
  value       = "Connect to the deployed instance: >>> ssh ${module.ec2_inst.ssh_key_name} <<<  "
}

output "aws_profile" {
  description = "Name of the AWS profile the EC2 instance is being created in"
  value       = module.ec2_inst.aws_profile
}

