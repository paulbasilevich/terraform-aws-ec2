#!/usr/bin/env bash

config_file=~/.ssh/config
config_save=~/.ssh/config_backup_tf

key_name="$1"
public_ip="$2"
user="$3"

# Save the original config file as an extra safety (courtesy)
if [[ ! -s "$config_save" ]]; then cp -fp "$config_file" "$config_save"; fi

# Remove the previous "Host $key_name" clause to support EC2 instance recreation:
sed -E -i -e "/^Host[[:space:]]+${key_name}$/,/^$/d" "$config_file"

# Append the config file with the new clause specification:
cat >> $config_file << TAG
Host $key_name
    ServerAliveInterval 60
    StrictHostKeyChecking no
    Port 22
    HostName $public_ip
    User $user
    IdentityFile ~/.ssh/${key_name}_rsa

TAG
