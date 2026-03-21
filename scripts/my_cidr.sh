#!/usr/bin/env bash

# Refer to https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external
# for details pertaining to the bash-terraform interface.

# This script evaluates the ingress CIDR block for the security group
# and returns the value to the calling "external" "my_cidr" data source.

# The script is "self-aware" of the hosting environment.
# The two options for CIDR block are available:
#   - <my_host>     this_IP/32
#   - <my_cidr>     the CIDR this host belongs in

# Arguments passed in through "external" "my_cidr" data source:
# CIDR_SCOPE : expects one of the two values:
#               my_host - sets master CIDR block to a single address - public IP of the local host
#               my_cidr - sets master CIDR block to the CIDR the local host belongs in
# EXTRA_CIDR : additional CIDR block optionally specified by the user (defaults to "none")
# VPC_CIDR   : the CIDR block allocated to the public subnet of the hosting VPC,
#              provided that there is also a private subnet set up in the VPC (otherwise - "none")
              
eval "$(jq -r '@sh "CIDR_SCOPE=\(.cidr_scope) EXTRA_CIDR=\(.extra_cidr) VPC_CIDR=\(.vpc_cidr)"')"

fmt_cidr="^[1-9][[:digit:]]{1,2}(.[[:digit:]]{1,3}){3}/[[:digit:]]{1,2}$"

case "$CIDR_SCOPE" in
    "my_host") RANGE="$( curl -4 -s https://ifconfig.me/ip )/32" ;;
    "my_cidr") RAW="$( whois $( dig TXT -4 +short o-o.myaddr.l.google.com @ns3.google.com \
               | tr -d "\"" ) | grep "CIDR:\|route:" \
               | sed -E -e "s~([^[:space:]]*[[:space:]]+)([^[:space:]]+)([[:print:]]*)~\2~")"
               unset RANGE
               for x in $( echo -e "$RAW" | egrep -x -e "$fmt_cidr" )
               do
                   if [[ -n "$RANGE" ]]; then RANGE+=" "; fi
                   RANGE+=$x
               done
               ;;
            *) RANGE="$( basename "$0" ): <$CIDR_SCOPE>"
               ;;
esac

for z in EXTRA_CIDR VPC_CIDR
do
    x="$( eval echo -e "\$$z" | egrep -x -e "$fmt_cidr" )"
    if [[ -n "$x" ]]; then RANGE+=" $x"; fi
done

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
