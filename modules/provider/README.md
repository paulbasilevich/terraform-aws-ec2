# terraform-aws-ec2
Terraform module:
Creates an EC2 instance and deploys Plaid Quickstart backend service on it.
Deploys the front end locally.

This submodule defines the external provider specs: <aws> and <external>.
The AWS profile can be set (overriden) in the top-level <terraform.tfvars> file (defaults to "default").

Note that the target AWS region gets retrieved from the profile as such, and thus "region" argument
used alongside "profile" in "provider" block is ignorred.

