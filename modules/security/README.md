# terraform-aws-ec2
Terraform module:
Creates the security group for the sought EC2 instance.

Retrieves the target CIDR block setting from the dependency module "cidr_blk":
        module.cidr_blk.cidr_blocks

Sets up access to ssh, http, port 8000 (for Plaid), and icmp.
