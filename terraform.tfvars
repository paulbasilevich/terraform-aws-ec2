# This variable defines how the backend infrastructure is to be deployed:
# -  public => backend runs on an instance deployed in a publicly accessible subnet
#              protected only by the rules of a security group
# - private => backend runs in a private subnet leveraging a load balancer
#              for access to public network
deployment_subnet = "private"
# deployment_subnet = "public"

# Update this variable with the desired ssh key name. ("h" implies "host".)
ssh_key_name = "h"

# Define EC2 instance type for each network, unless t2.micro is good enough.
subnet_config = [
    {
      role = "public"
      type = "t2.micro"
    },
    {
      role = "private"
      type = "t2.micro"
    }
]

# This is a "<tag name> = <the tag's value prefix>" template map.
# For each resource, each tag value will be set as <value prefix>-<resource type>.
# For example, EC2 instance: Name=Sandbox-EC2-private; Tier=Pilot-EC2-private
tags_bootstrap = {
  Name = "Sandbox"
  Tier = "Pilot"
}

# This variable defines CIDR block of IP addresses
# public ssh access to the front-end EC2 instance is permitted from.
# Acceptable values are:
#    -    my_host => <current_public_IP_address>/32
#    -    my_cidr => CIDR block encompassing that IP address
#    - extra_cidr => optional additional CIDR block
cidr_scope = "my_host"
# cidr_skope = "my_cidr"
# extra_cidr = "0.0.0.0/0"

# This variable defines the search pattern for picking up the EC2 base image
# out of available AMI options.
ami_name_pattern = "ubuntu"
# ami_name_pattern = "RHEL"
# ami_name_pattern = "Amazon Linux 2023"

# The name of the desired pre-configured operational AWS profile
# that specifies where the AWS resources are to be deployed.
aws_profile = "default"

