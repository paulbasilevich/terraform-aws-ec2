# terraform-aws-ec2
Terraform module:
creates an EC2 instance with access secured to the local host
deploys Plaid backend on the instance
deploys the front end locally.

This submodule defines the external provider specs: <aws> and <external>.
The AWS profile and region can be set (overriden) in the top-level <terraform.tfvars> file.
