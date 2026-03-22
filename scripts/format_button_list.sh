#!/usr/bin/env bash

# This script marshalls the list of button names (potentially with spaces)
# obtained from "external-to-bash" interface
# and applies it to the script that browses along the targeted web page

# Arguments passed in through "external" "format_button_list" data source:
# BUTTON_NAMES   - the formatted list of button names

eval "$(jq -r '@sh "BUTTON_NAMES=\(.button_names)"')"

BUTTON_NAMES="$( echo "$BUTTON_NAMES" | tr "\"" "'" | sed -E -e "s~,~& ~g" )"
browse_script="$( dirname "$0" )"/run_web_page.sh
sed -E -i '' -e "s~([[:space:]]*const[[:space:]]+buttons[[:space:]]*=[[:space:]]*)([^;]+)(;)~\1$BUTTON_NAMES\3~" \
    "$browse_script"

touch -c -r "$0" "$browse_script"

jq -n null

