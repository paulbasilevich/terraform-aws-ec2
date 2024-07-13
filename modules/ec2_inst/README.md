# terraform-aws-ec2
Terraform module:
Creates an EC2 instance with access secured to the local host
Deploys Plaid backend on the instance
Deploys the front end locally.

The instance gets deployed and provisioned for running Plaid backend to a pre-created dedicated VPC,
to its either public or private subnet depending on the terraform variable named <deployment_subnet> -
set to "public" or "private" respectively.

For "private" deployment, the traffic between the internet and the EC2 instance is handled by
a load balancer set up in the cited VPC.

In both types of deployment, the EC2 instance can be connected to through ssh from the local environment
by calling:     ssh <"Host" name configured by this module in ~/.ssh/config file. (Defaults to "plaid")>

In case of "private" deployment, the traffic is routed through a "bastion" - another EC2 instance
deployed by this module in the public subnet and defined in ~/.ssh/config file accordingly.
