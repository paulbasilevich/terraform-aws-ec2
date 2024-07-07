#!/usr/bin/env bash

# This script updated setupProxy.js file with the DNS either of the public host or the load balancer.
# Starts the front end Plaid Quickstart service upon the update.

# eval "$(jq -r '@sh "SSH_ALIAS=\(.ssh_alias) PLAID_HOME=\(.plaid_home) HOST_IP=\(.host_ip) PLAID_CLIENT_ID=\(.plaid_client_id) PLAID_SECRET=\(.plaid_secret)"')"

PLAID_HOME="$1"
BACKEND_URI="$2"
BACKEND_PORT="$3"

frontend_home="$PLAID_HOME/frontend"
setup_proxy_file="$frontend_home/src/setupProxy.js"
sed -E -i '' -e "s~(^[[:space:]]*target:[[:space:]]*process.env.REACT_APP_API_HOST[[:space:]]*\|\|[[:space:]]*\'http://)([^:]*)(:[[:digit:]]+)~\1${BACKEND_URI}:${BACKEND_PORT}~" "$setup_proxy_file"
index_file="$frontend_home/src/Components/Endpoint/index.tsx"
sed -E -i '' -e "s~(props.name)(==)~\1 =\2~" "$index_file"

pushd "$frontend_home" > /dev/null
npm install
test_connect=./tn.sh
cat >> "$test_connect" << EXP
#!/usr/bin/expect

set timeout 10
set host [lindex \$argv 0]
set port [lindex \$argv 1]

spawn telnet \$host \$port
expect "Escape character is '^]'."
send -- "\035"
expect "telnet>"
send -- "quit\r"
expect eof
EXP

chmod +x "$test_connect"
pause_seconds=10
attempts=60
result=1
while [[ $result -ne 0 && $attempts -gt 0 ]]
do
    "$test_connect" "$BACKEND_URI" "$BACKEND_PORT" > /dev/null 2>&1
    result=$?
    if [[ $result -ne 0 ]]; then sleep $pause_seconds; fi
    let attempts--
done    
rm -f "$test_connect"

tmux kill-session -t $PLAID_HOME 2> /dev/null
tmux new-session -d -s $PLAID_HOME 'npm start'
popd > /dev/null

# FOOBAZ="started"
# jq -n --arg foobaz "$FOOBAZ" '{"foobaz":$foobaz}'
# jq -n --arg plaid_started "$PLAID_STARTED" '{"plaid_started":$plaid_started}'


