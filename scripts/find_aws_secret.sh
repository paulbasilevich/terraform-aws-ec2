#!/usr/bin/env bash

# This script looks for the AWS SecretsManager object with the specified name.
# Returns the outcome of the search: success(0) or failure.

# Arguments passed in through "external" "locate_aws_secret" data source:
# AWS_SECRET_NAME - the name of the SecretsManager object

eval "$(jq -r '@sh "AWS_SECRET_NAME=\(.aws_secret_name)"')"

aws secretsmanager list-secrets | jq -r '.SecretList[]|.Name' | egrep -q -x -e "^${AWS_SECRET_NAME}$"
AWS_SECRET_STATUS=$?

if [[ $AWS_SECRET_STATUS -ne 0 ]]; then
    revert_script="$( dirname "$( realpath "$0" )" )/destroy_aws_secret.sh"
    # Update the revert_script only if there is no "#" on aws_secret_name= line: already updated.
    delims=$( cat "$revert_script" | grep "^aws_secret_name=" | tr -d '\n' | sed -E -e "s~[^#]~~g" | wc -c )
    if [[ $delims -eq 0 ]]; then
        sed -E -i '' -e "s~(^aws_secret_name=)([[:print:]]+)~\1\"${AWS_SECRET_NAME}\"\t# \2~" "$revert_script"
        touch -c -r "$0" "$revert_script"
    fi
fi

jq -n --arg aws_secret_status "$AWS_SECRET_STATUS" '{"aws_secret_status":$aws_secret_status}'

