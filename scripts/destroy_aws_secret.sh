#!/usr/bin/env bash

# This script is meant to destroy the AWS SecretsManager object
# previously deployed by terraform and then detached from it, i.e., autonomized.

# No arguments required
# Usage:  ./zds  (links to .../destroy_aws_secret.sh )

aws_secret_name="Vault"

arn="$( aws secretsmanager list-secrets --filters "Key=name,Values=$aws_secret_name" | jq -r '.SecretList[]|.ARN' )"

if [[ -n "$arn" ]]
then
    prompt="Destroy the AWS <$aws_secret_name> secret object (y/n)? "
    read -p "$prompt" response
    response="$( echo "${response:0:1}" | tr [:upper:] [:lower:] )"
    if [[ "$response" == "y" ]]
    then
        echo "Destroyed $( aws secretsmanager delete-secret --secret-id "$arn" --force-delete-without-recovery \
            | jq -r '.Name' )"
    fi
else
    echo "There is no <$aws_secret_name> secret in AWS SecretsManager."
fi

