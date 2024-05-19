# terraform-aws-ec2
Terraform module:
- creates an EC2 instance with access secured to the local host
- deploys Plaid backend on the instance
- deploys Plaid frontend locally.
- sets up the local ssh configuration for straightforward ssh access, namely:
    ssh <key pair name>   (e.g., ssh plaid)
