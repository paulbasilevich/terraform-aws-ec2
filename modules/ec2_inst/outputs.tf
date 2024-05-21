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

output "ssh_key_name" {
  value = module.key_pair.ssh_key_name
}

output "time" {
  description = "Time formatted and adjusted to PST/PDT"
  value       = local.time
}
