# terraform-aws-ec2
Terraform module:
creates an EC2 instance with access secured to the local host
deploys Plaid backend on the instance
deploys the front end locally.

This submodule supplies the ID of the AMI for the target EC2 instance.
Based on the wildcard name pattern of the sought AMI.
The installation of Plaid implelemnted only for Ubuntu platform in this release.
The AMI name pattern can be set (overriden) in the top-level <terraform.tfvars> file.


