#!/usr/bin/env bash

# This script prepares the environment for Plaid Quickstart service
# on the backend for Ubuntu operating platform

this_index="$1"
that_index="$(( $2 - 1 ))"
ssh_host="$3"
script="$4"
instance_id="$5"
if [[ $this_index -eq $that_index ]]
then
    aws ec2 wait instance-running   --instance-ids "$instance_id"
    aws ec2 wait instance-status-ok --instance-ids "$instance_id"
    scp "$script" ${ssh_host}:/tmp
fi
