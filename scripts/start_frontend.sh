#!/usr/bin/env bash

# This script updates setupProxy.js file with the public DNS name associated
# either of the host running in the public subnet
# or the load balancer routing traffic to and from the host deployed in the private subnet.

# Starts the frontend Plaid Quickstart service upon the update.
# Initiates the "welcome" dialog to come up once the page is up and running.

# Arguments:
# $1 - path to the directory hosting the cloned GitHub repository storing the Plaid source code
# $2 - public DNS of either the host running in the public subnet
#      or the load balancer routing traffic to and from the host deployed in the private subnet
# $3 - port number the backend service listens on (8000)
# $4 - type of the browser the frontend runs in (e.g., Chrome)
# $5 - the title of the web page to navigate

PLAID_HOME="$1"
BACKEND_DNS="$2"
BACKEND_PORT="$3"
BROWSER="$4"
TAB_TITLE="$5"

janitor="$( dirname "$0" )"/cleanup_ssh.sh  # This script handles the closing procedures
frontend_home="$PLAID_HOME/frontend"
setup_proxy_file="$frontend_home/src/setupProxy.js"

# Examine BACKEND_DNS for reachable IP:
TIMEOUT_SEC=3
CHANCES=3

ATTEMPT=0
retVal=1
while [[ $retVal -ne 0 || $ATTEMPT -lt $CHANCES ]]; do
    curl -s --connect-timeout $TIMEOUT_SEC http://${BACKEND_DNS}:${BACKEND_PORT} > /dev/null
    retVal=$?
    let ATTEMPT++
done

if [[ $retVal -ne 0 ]]; then
    IP_SET="$( nslookup "$BACKEND_DNS" | grep -E -o -e "([[:digit:]]{1,3}\.){3}[[:digit:]]{1,3}" | tr '\n' ' ' )"
    ATTEMPT=0
    retVal=1
    while [[ $retVal -ne 0 || $ATTEMPT -lt $CHANCES ]]; do
        for IP in ${IP_SET}; do
            curl -s --connect-timeout $TIMEOUT_SEC http://${IP}:${BACKEND_PORT} > /dev/null
            retVal=$?
            if [[ $retVal -eq 0 ]]; then
                BACKEND_DNS=${IP}
                break 2
            fi
        done
    done
fi

sed -E -i '' -e "s~(^[[:space:]]*target:[[:space:]]*process.env.REACT_APP_API_HOST[[:space:]]*\|\|[[:space:]]*\'http://)([^:]*)(:[[:digit:]]+)~\1${BACKEND_DNS}:${BACKEND_PORT}~" "$setup_proxy_file"

index_file="$frontend_home/src/Components/Endpoint/index.tsx"
sed -E -i '' -e "s~(props.name)(==)~\1 =\2~" "$index_file"

pushd "$frontend_home" > /dev/null
npm install
sleep 1
tmux kill-session -t $PLAID_HOME 2> /dev/null
sleep 1
tmux new-session -d -s $PLAID_HOME bash -c '
npm start
'
sleep 5
popd > /dev/null
sleep 5

"$( dirname "$0" )"/run_web_page.sh "$BROWSER" "$TAB_TITLE"
# Update the script that handles closing on "destroy"
sed -E -i '' -e "\
    s~(BROWSER=\")([^\"]+)(\")~\1$BROWSER\3~;
    s~(TAB_TITLE=\")([^\"]+)(\")~\1$TAB_TITLE\3~\
    " "$janitor"
touch -c -r "$0" "$janitor"
