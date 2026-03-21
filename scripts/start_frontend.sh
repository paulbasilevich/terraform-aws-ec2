#!/usr/bin/env bash

# This script updates setupProxy.js file with the public DNS name associated
# either of the host running in the public subnet
# or the load balancer routing traffic to and from the host deployed in the private subnet.

# Starts the frontend Plaid Quickstart service upon the update.

# Arguments:
# $1 - path to the directory hosting the cloned GitHub repository storing the Plaid source code
# $2 - public DNS of either the host running in the public subnet
#      or the load balancer routing traffic to and from the host deployed in the private subnet
# $3 - port number the backend service listens on (8000)

PLAID_HOME="$1"
BACKEND_DNS="$2"
BACKEND_PORT="$3"

frontend_home="$PLAID_HOME/frontend"
setup_proxy_file="$frontend_home/src/setupProxy.js"
sed -E -i '' -e "s~(^[[:space:]]*target:[[:space:]]*process.env.REACT_APP_API_HOST[[:space:]]*\|\|[[:space:]]*\'http://)([^:]*)(:[[:digit:]]+)~\1${BACKEND_DNS}:${BACKEND_PORT}~" "$setup_proxy_file"
index_file="$frontend_home/src/Components/Endpoint/index.tsx"
sed -E -i '' -e "s~(props.name)(==)~\1 =\2~" "$index_file"

pushd "$frontend_home" > /dev/null
npm install
sleep 1
tmux kill-session -t $PLAID_HOME 2> /dev/null
sleep 1
tmux new-session -d -s $PLAID_HOME 'npm start'
sleep 10
popd > /dev/null

