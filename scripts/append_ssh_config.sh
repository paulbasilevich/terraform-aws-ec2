#!/usr/bin/env bash

# This script updates the local ssh config file
# with the specs pertaining to the just created EC2 instance
# so that it could be connected to by simple "ssh <$key_name>" call.
# The original config file gets restored at "terraform destroy" time.

config_file=~/.ssh/config
config_save=~/.ssh/config_backup_tf

key_name="$1"
public_ip="$2"
user="$3"

# Save the original config file as an extra safety (courtesy)
cp -fp "$config_file" "$config_save"

cat >> $config_file << TAG
Host $key_name
    ServerAliveInterval 60
    StrictHostKeyChecking no
    Port 22
    HostName $public_ip
    User $user
    IdentityFile ~/.ssh/${key_name}.pem

TAG
