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
  value       = aws_instance.plaid["Plaid"].public_ip
}

output "ec2_instance_type" {
  description = "Type of the just-created EC2 instance"
  value       = aws_instance.plaid["Plaid"].instance_type
}

output "ssh_key_name" {
  value = module.key_pair.ssh_key_name
}

output "aws_profile" {
  value = module.security.aws_profile
}

output "time" {
  description = "Time formatted and adjusted to PST/PDT"
  value       = local.time
}

output "ami_name" {
  description = "Name of the AMI retrieved for the current region by AMI name pattern"
  value       = module.ami_data.ami_name
}
