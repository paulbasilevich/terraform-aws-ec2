#!/usr/bin/env bash

# This script updates the local ssh config file
# with the specs pertaining to the EC2 instance
# just created in the public subnet of the custom VPC
# so that the instance could be connected to by simple
# "ssh <$key_name>" call pattern.

# If the target instance running Plaid service is deployed
# in the private subnet, construes the instance running in the public subnet
# as a bastion for the target and adjusts the code block in ~/.ssh/config file accordingly.

# The original config file gets restored at "terraform destroy" time.

# Input arguments:
# $1 - 0 - for public subnet; 1 - for private subnet
# $2 - the number of instances deployed: 1 - one in the public subnet; 2 - another one in the private subnet
# $3 - the name of the AWS key pair
# $4 - user name for ssh connection to the EC2 instances
# $5 - EC2 instance ID the ~/.ssh/config file is being updated for
# $6 - the private IP address of the current EC2 instance
# $7 - the public IP of the same instance (or "null" for the instance deployed in the private subnet)

subnet_index="$1"
ec2_instance_count="$2"
key_name="$3"
user="$4"
instance_id="$5"
private_ip="$6"
public_ip="$7"

config_file=~/.ssh/config
config_save=~/.ssh/config_backup_tf
public_suffix="jump"

aws ec2 wait instance-status-ok --instance-ids "$instance_id"

# Save the original config file as an extra safety (courtesy)
if [[ $subnet_index -eq 0 ]]
then
    case $ec2_instance_count in
        1) host_name="$key_name" ;;
        *) host_name="${key_name}_${public_suffix}" ;;
    esac
    host_ip="$public_ip"
    cp -fp "$config_file" "$config_save"
else
    host_name="$key_name"
    host_ip="$private_ip"
fi    

cat >> $config_file << TAG
Host $host_name
    ServerAliveInterval 60
    StrictHostKeyChecking no
    Port 22
    HostName $host_ip
    User $user
    IdentityFile ~/.ssh/${key_name}.pem
TAG

if [[ $subnet_index -ne 0 ]]
then
    cat >> $config_file << TAG1
    ProxyJump ${key_name}_${public_suffix}
TAG1
fi

echo >> $config_file

