#!/usr/bin/env bash

# This script remotely runs the setup script
# that provisions the environment for Plaid Quickstart backend service.

# Arguments:
# $1 - the value of count.index: 0 - pertains public network; 1 - private network
# $2 - the value the above $1 has to match (i.e. "public" or "private" association)
#      for the provision to actually run
# $3 - "Host" name of the target EC2 instance in the context of ~/.ssh/config file
# $4 - path to the provisioning script file

this_index="$1"
that_index="$(( $2 - 1 ))"
ssh_host="$3"
script="$4"
if [[ $this_index -eq $that_index ]]
then
    remote_script="/tmp/$( basename "$script" )"
    ssh "$ssh_host" << EOT
chmod +x "$remote_script"
"$remote_script" "$ssh_host"
rm -f "$remote_script"
EOT
fi
