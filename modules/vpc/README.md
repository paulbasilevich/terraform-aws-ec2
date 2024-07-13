# terraform-aws-ec2

This module creates a VPC where the EC2 instance running Plaid backend service is meant to be deployed.

The VPC networking structure is controlled
by "deployment_subnet" environment variable, the default value set to "public".

For deployment_subnet = "public", the process involves the following logical steps:
 
    - Create a VPC with a single subnet open for public access.
 
    - Evaluate CIDR block for the target security group to authorize access to the would-be EC2 instance
      either from the local host or from the CIDR the local host belongs in.
 
    - Create the security group effective within the VPC.
 
    - Configure the public subnet, namely:
        * create the internet gateway
        * create the route table and set up the route from the public subnet to the internet gateway;
        * associate the route table with the public subnet;
 
For deployment_subnet = "private", the process performs the following extra steps:
    
    - In the security group, modify all ingress rules to accept traffic from the public subnet.
    
    - Create another subnet in the VPC in question and configure it as a private subnet:
        * in the public subnet, create the NAT gateway;
        * create another route table and set up the route from the private subnet to the NAT gateway;
        * associate the route table with the private subnet.
    
    - Set up a load balancer to control traffic between the public network and the Plaid Quickstart
      backend service host running in the private network, namely:
        * create the instance target group for the would-be load balancer; the target EC2 instance
          will be attached to that group upon creation;
        * create a load balancer spanning the public and the private subnets of the VPC;
        * within the load balancer, create a listener tuned up to the port exposed by
          the Plaid Quickstart backend service (port 8000)
        * take a note of the load balancer's DNS and leverage it in configuring the frontend service
          before starting it
        
