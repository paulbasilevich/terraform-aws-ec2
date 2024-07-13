# terraform-aws-ec2
Terraform module:
creates an EC2 instance with access secured to the local host
deploys Plaid backend on the instance
deploys the front end locally.

This submodule creates a key pair for SSH access to the target EC2 instances
being deployed in the public and, optionally, private subnet of the pre-created hosting VPC.

The key name defaulted to <plaid> can be set (overriden) in the top-level <terraform.tfvars> file.

Updates ~/.ssh/config file to streamline the SSH connection down to the following instruction:
        ssh plaid

That SSH connection signature transparently works both for "public" and "private" deployments
insofar as, for the private deployment, a bastion host gets automatically defined in ~/.ssh/config file
for the host running Plaid backend service in the private subnet.

Restores the original content of ~/.ssh directory at <terraform destroy>.

