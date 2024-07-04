#!/usr/bin/env bash

# This script prepares the environment for Plaid Quickstart service
# on the backend for Ubuntu operating platform

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
