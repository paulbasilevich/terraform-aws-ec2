# terraform-aws-ec2
Terraform module:
Creates the security group for the sought EC2 instance.

Evaluates the target CIDR block as either "this-IP/32" or "this CIDR"
as controlled by var.cidr_scope setting.

Sets up access to ssh, http, and icmp.
