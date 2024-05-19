output "tf_sg" {
  description = "Security group Id for the EC2 instance being created"
  value       = aws_security_group.tf_sg.id
}
