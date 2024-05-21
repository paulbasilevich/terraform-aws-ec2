output "tf_sg" {
  description = "Security group Id for the EC2 instance being created"
  value       = aws_security_group.tf_sg.id
}

output "aws_region" {
  value = module.cidr_blk.aws_region
}

output "aws_profile" {
  value = module.cidr_blk.aws_profile
}


