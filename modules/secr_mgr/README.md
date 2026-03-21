# terraform-aws-ec2
Terraform module:
Creates an EC2 instance with access secured to the local host.
Deploys Plaid backend on the instance.
Deploys the front end locally.

This submodule checks if AWS SecretsManager object with the specified name
(retrieved from the top level terraform.tfvars file) exists.
If so, pulls the Plaid credentials from it.
Otherwize, looks for those in the local environment (~/.bash_profile).

