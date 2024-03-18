output "ssh" {
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
output "now" {
  description = "Time formatted and adjusted to PST/PDT"
  value       = local.time
}

output "cbl" {
  description = "CIDR block evaluated as either <my_host> or <my_cidr> option"
  value       = join(", ", module.security.cidr_blocks)
}

