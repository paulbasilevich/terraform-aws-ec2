#!/usr/bin/env bash

# This script creates the key-pair object in AWS EC2
# and returns the generated private key to the calling module.
# Also saves the private key as a *.pem file in ~/.ssh directory

eval "$(jq -r '@sh "KEY_NAME=\(.ssh_key_name) SSH_TAG=\(.ssh_config_tag) ENV_STATUS=\(.env_status)"')"
# SSH_TAG is merely to demonstrate multiple input json key-pairs.
# Here .ssh_key_name is the only attribute retrievable from "self" - a must for destroyer-provisioner.
# The idea is to maintain consistency between "apply" and "destroy" functionality.
# In fact, SSH_TAG is not used in this script.

if [[ $ENV_STATUS -eq 0 ]]
then
    pk_file=~/.ssh/${KEY_NAME}.pem

    # Check if the key already exists and delete it if so
    is_key_there="$(
    aws ec2 describe-key-pairs --key-names "$KEY_NAME" 2> /dev/null \
        | jq -r '.KeyPairs[]|.KeyName'
    )"

    if [[ "$is_key_there" == "$KEY_NAME" ]]; then aws ec2 delete-key-pair --key-name "$KEY_NAME"; fi
    if [[ -f "$pk_file" ]]; then rm -f "$pk_file"; fi

    # Create the private key and save it in $pk_file
    aws ec2 create-key-pair --key-name "$KEY_NAME" | jq -r '.KeyMaterial' > "$pk_file"
    chmod 400 "$pk_file"
    # Here we cannot append ~/.ssh/config with the new Host definition: HostName and User are not known yet

    PRIVATE_KEY="$( cat "$pk_file" )"
else
    PRIVATE_KEY=$ENV_STATUS
fi

jq -n --arg private_key "$PRIVATE_KEY" '{"private_key":$private_key}'

