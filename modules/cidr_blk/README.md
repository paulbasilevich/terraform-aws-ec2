# terraform-aws-ec2
Terraform module:
Creates an EC2 instance with access secured to the local host.
Deploys Plaid backend on the instance.
Deploys the front end locally.

This submodule creates ingress CIDR block specification for the security group
meant for the sought EC2 instance.

The logic is determined by the value of <cidr_scope> variable, namely:
    cidr_scope = "my_host"      - the CIDR block is <the public IP address of the current host>/32
    cidr_scope = "my_cidr"      - the CIDR block is the IP address range the current host belongs in

Optionally, an explicitly defined IP address range can be added to the target CIDR by way of assigning another
variable as follows, e.g.:
    extra_cidr = "37.19.211.0/24"

All those variables can be set (overriden) in the top-level <terraform.tfvars> file.

If the target EC2 instance is deployed in the private subnet, complements the block
with the CIDR block allocated for the public subnet of the hosting VPC.










Creates the CIDR block specification for the security group meant for the sought EC2 instance.

