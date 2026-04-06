# terraform-aws-ec2
Terraform module:
Creates an EC2 instance and deploys Plaid Quickstart backend service on it.
Deploys the front end locally.

This submodule:

Creates the security group for the sought EC2 instance.
Sets up access to ssh, http, port 8000 (for Plaid), and icmp.
