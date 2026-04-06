#!/usr/bin/env bash

# This script looks for the AWS SecretsManager object with the specified name.
# Returns the outcome of the search: success(0) or failure.

# Arguments passed in through "external" "locate_aws_secret" data source:
# AWS_SECRET_NAME - the name of the SecretsManager object

eval "$(jq -r '@sh "AWS_SECRET_NAME=\(.aws_secret_name)"')"

aws secretsmanager list-secrets | jq -r '.SecretList[]|.Name' | egrep -q -x -e "^${AWS_SECRET_NAME}$"
AWS_SECRET_STATUS=$?

revert_script="$( dirname "$( realpath "$0" )" )/destroy_aws_secret.sh"
sed -E -i '' -e "s~(aws_secret_name=\")([^\"]+)(\")~\1${AWS_SECRET_NAME}\3~" "$revert_script"
touch -c -r "$0" "$revert_script"

jq -n --arg aws_secret_status "$AWS_SECRET_STATUS" '{"aws_secret_status":$aws_secret_status}'

