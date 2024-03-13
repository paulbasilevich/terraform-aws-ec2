# terraform-aws-ec2
Terraform module:
Creates ssh key-pair and wraps it up into aws_key_pair resource.
Drops the private key file (a.k.a. IdentityFile) in ~/.ssh directory.

At creation of aws_instance resource,
the ~/.ssh/config file gets updated with the pertaining HostName, User, and IdentityFile
