# output "now" {
#   description = "Time formatted and adjusted to PST/PDT"
#   value       = local.time
# }

output "_" {
  description = "Shell command to connect to the target host"
  value       = "Connect to the deployed instance: >>> ssh ${module.ec2_inst.ssh_key_name} <<<  "
}

# output "public_ip" {
#   value = module.ec2_inst.public_ip
# }

# output "region" {
#   value = module.ec2_inst.aws_region
# }
