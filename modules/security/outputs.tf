output "tf_sg" {
  description = "Security group Id for the EC2 instance being created"
  value       = aws_security_group.tf_sg.id
}

output "cidr_blocks" {
  # value = [join(",", values(data.external.my_cidr.result))]
  # value = join(",", values(data.external.my_cidr.result))
  # value = split(",", join(",", values(data.external.my_cidr.result)))
  # value = split(" ", values(data.external.my_cidr.result)[0])
  value = local.cidr_blocks
}

output "goal" {
  value = ["143.244.32.0/19", "143.244.46.0/24"]
}
