#!/usr/bin/env bash

# This script looks for the AWS SecretsManager object with the specified name.
# Returns the outcome of the search: success(0) or failure.

eval "$(jq -r '@sh "AWS_SECRET_NAME=\(.aws_secret_name)"')"

aws secretsmanager list-secrets | jq -r '.SecretList[]|.Name' | egrep -q -x -e "^${AWS_SECRET_NAME}$"
AWS_SECRET_STATUS=$?

jq -n --arg aws_secret_status "$AWS_SECRET_STATUS" '{"aws_secret_status":$aws_secret_status}'

