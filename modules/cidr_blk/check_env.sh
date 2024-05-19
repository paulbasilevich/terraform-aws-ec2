#!/usr/bin/env bash

# eval "$(jq -r '@sh "ENV_STATUS=\(.env_status)"')"

prefix="PLAID"
roleset=("CLIENT_ID" "SECRET")

fmt_CLIENT_ID="^[[:xdigit:]]{24}$"
fmt_SECRET="^[[:xdigit:]]{30}$"

ENV_STATUS=0
for role in ${roleset[@]}
do
    ienv="${prefix}_$role"
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
        fi
    fi
done

jq -n --arg env_status "$ENV_STATUS" '{"env_status":$env_status}'

