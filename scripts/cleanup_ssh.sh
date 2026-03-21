#!/usr/bin/env bash

# This script restores the original state of ~/.ssh directory
# effective before "terraform apply".
# Also terminates the tmux session running Plaid frontend locally.

# Arguments:
# $1 : if set to "0", the script is called with count.index=0,
#      which is associated with the first pass at "terraform destroy"
#      where the script only needs to run

once="$1"
if [[ $once -eq 0 ]]; then
    instance_id="$2"

    reset_timestamp_from="$( dirname "$0" )/start_frontend.sh"
    PLACEHOLDER="dummy"
    PUBLIC_SUFFIX="$PLACEHOLDER"
    BROWSER="$PLACEHOLDER"
    TAB_TITLE="$PLACEHOLDER"
    "$( dirname "$0" )"/destroy_web_page.sh "$BROWSER" "$TAB_TITLE"

    read key_name state <<<"$( aws ec2 describe-instances --instance-ids ${instance_id} \
        | jq -r '.Reservations[]|.Instances[]|[.KeyName, .State.Name]|@tsv' )"

    if [[ -n "$key_name" ]]; then
        aws ec2 delete-key-pair --key-name "${key_name}"
        rm -f ~/.ssh/${key_name}.pem
        sed -E -i '' -e "\
            /^Host[[:space:]]+${key_name:-$PLACEHOLDER}$/,/^$/d;\
            /^Host[[:space:]]+${key_name:-$PLACEHOLDER}${public_suffix}$/,/^$/d\
            " ~/.ssh/config
        if [[ -f ~/.ssh/config_backup_tf ]]; then
            mv -f ~/.ssh/config_backup_tf ~/.ssh/config
        fi
        # vvv Remove the local clone of the Plaid git repository
        rm -rf "${key_name}"

        tmux kill-session -t ${key_name} 2> /dev/null
    fi

    # Reinstate the original version of this file:
    exec bash -c "\
    sed -E -i '' -e \"s~(PUBLIC_SUFFIX|BROWSER|TAB_TITLE)(=\\\")([^\\\"]+)(\\\")~\1\2\\\$PLACEHOLDER\4~\" \"$0\" \
    && touch -c -r \"$reset_timestamp_from\" \"$0\" \
    "
fi
