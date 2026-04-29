#!/usr/bin/env bash

# This script is meant to destroy the AWS SecretsManager object
# previously deployed by terraform and then detached from it, i.e., autonomized.

# No arguments required
# Usage:  ./zds  (links to .../destroy_aws_secret.sh )

reset_timestamp_from="$( find . -type f -name "retain_aws_secret.sh" )"
this_path="$( realpath "$0" )"
PLACEHOLDER="Vault"

aws_secret_name="Plaid_runit-secr"	# "$PLACEHOLDER"

arn="$( aws secretsmanager list-secrets --filters "Key=name,Values=$aws_secret_name" | jq -r '.SecretList[]|.ARN' )"

if [[ -n "$arn" ]]; then
    prompt="Destroy the AWS <$aws_secret_name> secret object (y/n)? "
    read -p "$prompt" response
    response="$( echo "${response:0:1}" | tr [:upper:] [:lower:] )"
    if [[ "$response" == "y" ]]; then
        echo "Destroyed $( aws secretsmanager delete-secret --secret-id "$arn" --force-delete-without-recovery \
            | jq -r '.Name' )"
          # Reinstate the original version of this file:
            exec bash -c "\
                sed -E -i '' -e \"s~(^aws_secret_name=)([^#]+#[[:space:]]*)([[:print:]]+)~\1\3~\" \"$this_path\" \
                && touch -c -r \"$reset_timestamp_from\" \"$this_path\"                
            "        
    fi
else
    echo "There is no <$aws_secret_name> secret in AWS SecretsManager."
fi

