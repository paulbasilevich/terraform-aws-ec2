#!/usr/bin/env bash

# This script is meant to destroy the AWS SecretsManager object
# previously deployed by terraform and then detached from it.
#
# Takes an optional argument - the name of the Secret to be destroyed
# The default name of the secret it attempted to be found in terraform.tfvars file
#

default="$( grep aws_secret_name terraform.tfvars | cut -d\" -f2 )"
default="${default:-Plaid_Credentials_0}"
aws_secret_name="${1:-$default}"

arn="$( aws secretsmanager list-secrets --filters "Key=name,Values=$aws_secret_name" | jq -r '.SecretList[]|.ARN' )"

if [[ -n "$arn" ]]
then
    aws secretsmanager delete-secret --secret-id "$arn" --force-delete-without-recovery
else
    echo "There is no <$aws_secret_name> secret in AWS SecretsManager."
fi

