#!/usr/bin/env bash

# This script removes the SecretsManager object out of terraform
# thus persisting the object in AWS for further reuse.

# Check if there is secr_mrg module is managed by terraform
module="secr_mgr"
pattern="module.${module}.aws_secretsmanager_secret"
template="[[:print:]]*module.ec2_inst.module.key_pair.$pattern"

terraform state list | grep -q "$pattern"
if [[ $? -eq 0 ]]
then
    prompt="Release the AWS SecretsManager object from terraform (y/n)? "
    read -p "$prompt" response
    response="$( echo "${response:0:1}" | tr [:upper:] [:lower:] )"

    if [[ "$response" == "y" ]]
    then
        fullspec="$( terraform state list | egrep -o "$template" | head -1 )" 
        terraform state rm "$fullspec"
        echo
        echo "To destroy the rest of the deployed resourses run: terraform destroy -auto-approve"
    fi
else
    echo "Module <${module}> is not managed by terraform."
fi

