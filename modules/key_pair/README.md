# terraform-aws-ec2
Terraform module:
creates an EC2 instance with access secured to the local host
deploys Plaid backend on the instance
deploys the front end locally.

This submodule creates the key pair for SSH access to the target EC2 instance.
The key name defaulted to <plaid> can be set (overriden) in the top-level <terraform.tfvars> file.
Updates ~/.ssh/config file to streamline the SSH connection down to the following instruction:
        ssh plaid
Restores the original content of ~/.ssh directory at <terraform destroy>.

