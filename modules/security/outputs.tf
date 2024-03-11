output "tf_sg" {
  description = "Security group Id for the EC2 instance being created"
  value       = aws_security_group.tf_sg.id
}

# output "my_cidr" {
#   description = "CIDR idenfitied as only-this-host, i.e., my-public-IP/32"
#   value       = join(",", values(data.external.my_cidr.result))
# }
# 
# output "ssh_key_name" {
#   description = "Name of the dynamically generated ssh key for connection to the EC2 instance"
#   value       = var.ssh_key_name
# }
# 
# output "private_key" {
#   description = "Private key string generated for ssh_key_name"
#   value       = join(",", values(data.external.private_key.result))
# }
# 
# output "source" {
#   description = "Path to this location"
#   value = path.module
# }
