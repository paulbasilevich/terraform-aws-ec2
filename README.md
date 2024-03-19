# terraform-aws-ec2
Terraform module:

Creates an EC2 instance. 

Secures ssh, http, and icmp access to the local host
or the CIDR block the host belongs in.

SSH access to the created instance is immediately available
through the following call, its support automatically configured:

            ssh tf


Upon completion of the standard Provision Instructions,
please run the following additional initialization command:

        .terraform/modules/ec2/examples/init

        
