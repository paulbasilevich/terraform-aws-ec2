#!/usr/bin/env bash

# This script removes the SecretsManager object out of terraform
# thus persisting the object in AWS for further reuse.

# Check if there is secr_mrg module is managed by terraform
module="secr_mgr"
pattern="module.${module}.aws_secretsmanager_secret"

terraform state list | grep -q "$pattern"
if [[ $? -eq 0 ]]
then
    prompt="Release the AWS SecretsManager object from terraform (y/n)? "
    read -p "$prompt" -rsn1 response
    response="$( echo "$response" | tr [:upper:] [:lower:] )"

    if [[ "$response" == "y" ]]
    then
        terraform state rm "$module"
        echo
        echo "To destroy the rest of the deployed resourses run: terraform destroy -auto-approve"
    fi
else
    echo "Module <${module}> is not managed by terraform."
fi

