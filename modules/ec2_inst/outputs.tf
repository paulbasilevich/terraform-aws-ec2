output "_-" {
  description = "Shell command to connect to the web server host"
  value       = "SSH to web server host : ssh ${module.key_pair.ssh_key_name}"
}

output "__" {
  description = "Shell command to connect to the front-end host"
  value = (
    module.security.ec2_instance_count > 1
    ? "SSH to front-end host  : ssh ${module.key_pair.ssh_key_name}${var.lb_suffix}"
    : null
  )
}

output "ec2_instance_type" {
  description = "Type of the just-created EC2 instance"
  value       = join(", ", aws_instance.pilot[*].instance_type)
}

output "aws_profile" {
  description = "Name of the AWS profile where the EC2 instance is deployed"
  value       = module.security.aws_profile
}

output "deployed_at" {
  description = "Time formatted and adjusted to PST/PDT"
  value       = module.security.deployed_at
}

output "ami_name" {
  description = "Name of the AMI retrieved for the current region by AMI name pattern"
  value       = module.ami_data.ami_name
}

output "cidr_block" {
  description = "CIDR block evaluated as either <my_host> or <my_cidr> option"
  value       = module.security.cidr_block
}

output "common_tags" {
  description = "Tag prefix to be applied to all resource tags."
  value       = join(", ", [for k, v in module.security.common_tags[0] : "${k} = ${regex("[^-]+", "${v}")}"])
}

output "subnet_access" {
  description = "Label subnets as public and private, if the web host runs in private"
  value = (
    module.security.ec2_instance_count > 1
    ? join(", ", [for x in module.security.subnet_suffix : regex("[^-]+", x)])
    : null
  )
}

output "lb_dns_name" {
  description = "DNS record of the AWS Load balancer to check before starting front end"
  value       = module.security.lb_dns_name
}

