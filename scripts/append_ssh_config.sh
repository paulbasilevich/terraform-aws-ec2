#!/usr/bin/env bash

# This script updates the local ssh config file
# with the specs pertaining to the just created EC2 instance
# so that it could be connected to by simple "ssh <$key_name>" call.
# The original config file gets restored at "terraform destroy" time.

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

