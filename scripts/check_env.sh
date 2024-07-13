#!/usr/bin/env bash

# This script verifies whether PLAID_CLIENT_ID and PLAID_SECRET variables
# are properly defined in the local environment,
# unless the AWS SecretsManager object storing the sought values is available.
# If neither the SecretsManager object nor both variables found, flags the environment as faulty.

# Arguments passed in through "external" "check_env" data source:
# AWS_SECRET_STATUS : 0 - if the SecretsManager object exists; 1 - otherwise

eval "$(jq -r '@sh "AWS_SECRET_STATUS=\(.aws_secret_status)"')"

CLIENT_VAR_NAME="PLAID_CLIENT_ID"
SECRET_VAR_NAME="PLAID_SECRET"
ENV_STATUS=0

if [[ $AWS_SECRET_STATUS -ne 0 ]]
then
    name_prefix="PLAID"
    role_client="${CLIENT_VAR_NAME#*_}"
    role_secret="${SECRET_VAR_NAME#*_}"
    roleset=("$role_client" "$role_secret")

    fmt_CLIENT_ID="^[[:xdigit:]]{24}$"
    fmt_SECRET="^[[:xdigit:]]{30}$"

    for role in ${roleset[@]}
    do
        ienv="${name_prefix}_$role"
        ival="$( eval echo \"\$$ienv\" )"

        if [[ -z "$ival" ]]
        then
            let ENV_STATUS++
        else
            syntax="$( eval echo \"\$fmt_$role\" )"
            echo "$ival" | egrep -q -x -e "$syntax"
            if [[ $? -ne 0 ]]
            then
                let ENV_STATUS++
            else
                eval ${ienv}=$ival
            fi
        fi
    done
fi

jq -n \
      --arg env_status           "$ENV_STATUS" \
      --arg plaid_client_id      "$PLAID_CLIENT_ID" \
      --arg plaid_secret         "$PLAID_SECRET" \
      '{
        "env_status":$env_status, 
        "plaid_client_id":$plaid_client_id,
        "plaid_secret":$plaid_secret
       }'

