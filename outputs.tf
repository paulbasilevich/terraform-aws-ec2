output "_-" {
  description = "Shell command to connect to the web server host"
  value       = module.ec2_inst._-
}

output "__" {
  description = "Shell command to connect to the load balancer (bastion) host"
  value       = module.ec2_inst.__
}

output "ec2_instance_type" {
  description = "Type of the just-created EC2 instance"
  value       = module.ec2_inst.ec2_instance_type
}

output "aws_profile" {
  description = "Name of the AWS profile where the EC2 instance is deployed"
  value       = module.ec2_inst.aws_profile
}

output "deployed_at" {
  description = "Time formatted and adjusted to PST/PDT"
  value       = module.ec2_inst.deployed_at
}

output "ami_name" {
  description = "Name of the AMI retrieved for the current region by AMI name pattern"
  value       = module.ec2_inst.ami_name
}

output "cidr_block" {
  description = "CIDR block evaluated as either <my_host> or <my_cidr> option"
  value       = module.ec2_inst.cidr_block
}

output "common_tags" {
  description = "Tag prefix to be applied to all resource tags."
  value       = module.ec2_inst.common_tags
}

output "subnet_access" {
  description = "Label subnets as public and private, if the web host runs in private"
  value = module.ec2_inst.subnet_access
}

output "lb_dns_name" {
  description = "DNS record of the AWS Load balancer to check before starting front end"
  value = module.ec2_inst.lb_dns_name
}
