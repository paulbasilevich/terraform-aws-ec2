#!/usr/bin/env bash

# This script uploads the Plaid service provisioning script to the EC2 instance
# set up for that service.
# Works invariantly whether the target EC2 instance runs in the public or private subnet.

# Arguments:
# $1 - the value of count.index: 0 - pertains to public network; 1 - private network
# $2 - the value the above $1 has to match (i.e. "public" or "private" association)
#      for the mainstream logic to actually run
# $3 - "Host" name of the target EC2 instance in the context of ~/.ssh/config file
# $4 - path to the provisioning script file
# $5 - the AWS ID of the target EC2 instance


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
