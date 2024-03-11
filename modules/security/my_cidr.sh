#!/usr/bin/env bash

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

echo "{\"a\": \"$( dig -4 +short myip.opendns.com @resolver3.opendns.com )/32\"}"

