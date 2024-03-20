#!/usr/bin/env bash

eval "$(jq -r '@sh "HOST=\(.host)"')"

ostype="$( uname -a | cut -d' ' -f1 )"
case "$ostype" in
    "Linux")
# HOST="${HOST:-p}"
config_file="$HOME/.ssh/config"
clause="^Host[[:space:]]+${HOST}[[:space:]]*$"        # Host p - the sought config section
mean=("host" "user" "pkid")                           # Entries in config could be in any order
declare -A desc=(
    [host]="HostName"
    [user]="User"
    [pkid]="IdentityFile"
)

fmt_host="^[1-9][[:digit:]]{2}(.[[:digit:]]{1,3}){3}$"
fmt_user="^[[:alpha:]][[:alnum:]_.]+$"
fmt_pkid="^~/.ssh/[[:alnum:]_]+$"

for x in $( sed -E -n "/$clause/,/^[[:space:]]*$/p" "$config_file" \
    | grep "HostName\|User\|IdentityFile" \
    | awk '{print $2}' )
do
    for fnc in ${mean[@]}
    do
        syn="$( eval echo \"\$fmt_$fnc\" )"
        echo "$x" | egrep -q -x -e "$syn"
        if [[ $? -eq 0 ]]
        then
            eval $fnc="$x"
            break
        fi
    done
done

err_count=0
err_msg="ERROR - From ~/.ssh/$( basename "$config_file" ) for <$HOST> host could not evaluate:"
for fnc in ${mean[@]}
do
    if [[ -z "$( eval echo \"\$$fnc\" )" ]]
    then
        let err_count++
        err_msg+=" ${desc[$fnc]}"
    fi
done


# Placeholder for whatever data-fetching logic your script implements
if [[ $err_count -eq 0 ]]
then
    # host="$( dig -4 +short myip.opendns.com @resolver3.opendns.com )"
    CONNECT="ssh -i $pkid $user@$host open"
else
    CONNECT="$err_msg"
fi    
    ;;

    *) CONNECT="open" ;;
esac    

# Safely produce a JSON object containing the result value.
# jq will ensure that the value is properly quoted
# and escaped to produce a valid JSON string.
jq -n --arg connect "$CONNECT" '{"connect":$connect}'
