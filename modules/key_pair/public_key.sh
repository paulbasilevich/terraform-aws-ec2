#!/usr/bin/env bash

# This script leverages ssh-keygen utility to generate the ssh keys
# and return the public key to the calling terraform data source.

# Refer to https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external
# for details pertaining to the bash-terraform interface 

eval "$(jq -r '@sh "KEY_NAME=\(.ssh_key_name) SSH_TAG=\(.ssh_config_tag)"')"
# SSH_TAG is merely to demonstrate multiple input json key-pairs.
# Here .ssh_key_name is the only attribute retrievable from "self" - a must for destroyer-provisioner.
# The idea is to maintain consistency between "apply" and "destroy" functionality.
# In fact, SSH_TAG is not used in this script.

key_type="rsa"  # Alternative: ed25519
priv_file=~/.ssh/${KEY_NAME}_rsa
publ_file="${priv_file}.pub"

# Check if the key already exists and delete it if so
is_key_there="$(
aws ec2 describe-key-pairs --key-names "$KEY_NAME" 2> /dev/null \
    | jq -r '.KeyPairs[]|.KeyName'
)"

if [[ "$is_key_there" == "$KEY_NAME" ]]; then aws ec2 delete-key-pair --key-name "$KEY_NAME"; fi
if [[ -f "$priv_file" ]]; then rm -f "$priv_file"; fi
if [[ -f "$publ_file" ]]; then rm -f "$publ_file"; fi

ssh-keygen -t "$key_type" -f "$priv_file" -N "" > /dev/null

PUBLIC_KEY="$( cat "$publ_file" )"
jq -n --arg public_key "$PUBLIC_KEY" '{"public_key":$public_key}'

rm -f "$publ_file"

