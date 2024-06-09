#!/usr/bin/env bash

# This script restores the original state of ~/.ssh directory
# effective before "terraform apply".
# Also terminates the tmux session running Plaid frontend

instance_id="$1"
key_name="$( aws ec2 describe-instances --instance-ids ${instance_id} \
    | jq -r '.Reservations[]|.Instances[]|.KeyName' )"
aws ec2 delete-key-pair --key-name "${key_name}"
rm -f ~/.ssh/${key_name}.pem
sed -E -i -e "/^Host[[:space:]]+${key_name}$/,/^$/d" ~/.ssh/config
if [[ -f ~/.ssh/config_backup_tf ]]; then mv -f ~/.ssh/config_backup_tf ~/.ssh/config; fi
# vvv Remove the local clone of the Plaid git repository
rm -rf "${key_name}"

tmux kill-session -t ${key_name}
