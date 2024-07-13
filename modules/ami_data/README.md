# terraform-aws-ec2
Terraform module:
Creates an EC2 instance with access secured to the local host.
Deploys Plaid backend on the instance.
Deploys the front end locally.

This submodule supplies the ID of the AMI for the target EC2 instance
retrieved based on the user-provided wildcard name pattern of the sought AMI.

The installation of Plaid has been tested only for Ubuntu and RHEL platforms in this release.
The AMI name pattern can be set (overriden) in the top-level <terraform.tfvars> file.


