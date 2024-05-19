# terraform-aws-ec2
Terraform module:
creates an EC2 instance with access secured to the local host
deploys Plaid backend on the instance
deploys the front end locally.

This submodule creates CIDR block specification for the security group meant for the sought EC2 instance.
The logic is determined by the value of <cidr_scope> variable, namely:
    cidr_scope = "my_host"      - the CIDR block is <the public IP address of the current host>/32
    cidr_scope = "my_cidr"      - the CIDR block is the IP address range the current host belongs in

Optionally, an explicitly defined IP address range can be added to the target CIDR by way of assigning another
variable as follows, e.g.:
    extra_cidr = "10.0.0.0/16"

All those variables can be set (overriden) in the top-level <terraform.tfvars> file.










Creates the CIDR block specification for the security group meant for the sought EC2 instance.

