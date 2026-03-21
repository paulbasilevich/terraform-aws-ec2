# terraform-aws-ec2
Terraform module:
Creates an EC2 instance with access secured to the local host.
Deploys Plaid backend on the instance.
Deploys the front end locally.

This submodule:

Creates the security group for the sought EC2 instance.
Sets up access to ssh, http, port 8000 (for Plaid), and icmp.
