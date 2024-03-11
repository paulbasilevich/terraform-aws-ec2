output "ami" {
  description = "AMI Id retrieved for the current region by AMI name pattern"
  value       = data.aws_ami.ec2_ami.id
}

output "ami_name" {
  description = "Name of the AMI retrieved for the current region by AMI name pattern"
  value       = data.aws_ami.ec2_ami.name
}

output "instance_type" {
  description = "Free-tier instance type protected from external override"
  value       = local.instance_type
}

output "user" {
  description = "EC2 login account for the AMI type in use"
  value       = startswith(data.aws_ami.ec2_ami.name, "amzn2-") ? "ec2-user" : "ubuntu"
}

