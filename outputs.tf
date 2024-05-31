output "_" {
  description = "Shell command to connect to the target host"
  value       = module.ec2_inst._
}

output "aws_profile" {
  description = "Name of the AWS profile the EC2 instance is being created in"
  value       = module.ec2_inst.aws_profile
}

