#!/usr/bin/env bash

# Refer to https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external
# for details pertaining to the bash-terraform interface

# This script evaluates CIDR block for the security group
# and returns the value to the calling "external.my_cidr" data source

# The script is "self-aware" of the hosting environment.
# The two options for CIDR block are available:
#   - <my_host>     this_IP/32
#   - <my_cird>     the CIDR this host belongs in

eval "$(jq -r '@sh "CIDR_SCOPE=\(.cidr_scope)"')"

case "$CIDR_SCOPE" in
    "my_host") RANGE="$( curl -4 -s https://ifconfig.me/ip )/32" ;;
    "my_cidr") RAW="$( whois $( dig TXT -4 +short o-o.myaddr.l.google.com @ns3.google.com \
               | tr -d "\"" ) | grep "CIDR:\|route:" \
               | sed -E -e "s~([^[:space:]]*[[:space:]]+)([^[:space:]]+)([[:print:]]*)~\2~")"
               unset RANGE
               fmt_cidr="^[1-9][[:digit:]]{1,2}(.[[:digit:]]{1,3}){3}/[[:digit:]]{1,2}$"
               for x in $( echo -e "$RAW" | egrep -x -e "$fmt_cidr" )
               do
                   if [[ -n "$RANGE" ]]; then RANGE+=" "; fi
                   RANGE+=$x
               done
               ;;
            *) RANGE="$( basename "$0" ): <$CIDR_SCOPE>"
               ;;
esac

jq -n --arg cidr_range "$RANGE" '{"cidr_range":$cidr_range}'


#
#
# -- This is a working sample script compatible with Terraform "external" provider.
#    Specifically retrieves the IP address of the calling environment and builds the CIDR appending "/32".

# In general, such script should:
# -- calculate/evaluate/retrieve any data value and assign it to a variable, e.g., "result";
# -- use that "result" as a value in a key-value pair with an arbitrary key name, e.g. "a": "$result";
# -- echo out that key-value pair as a json statement: echo "{\"a\": \"$result\"}"

# Once the script is ready, set up a "*.tf" file in the same directory alongside the script. e.g., os_data.tf.
# In that .tf file, define an "external" data source and name it, e.g., "my_cidr":

#           data "external" "my_cidr" {
#             program = ["bash", "${path.module}/my_cidr.sh"]
#           }

# To incorporate $result value in any TF statement that relies on it, 
# use the following signature on the spot where $result is expected:

#               join(",", values(data.external.my_cidr.result))

# Example:      cidr_blocks = [join(",", values(data.external.my_cidr.result))]

# echo "{\"a\": \"$( curl -4 -s https://ifconfig.me/ip )/32\"}"
