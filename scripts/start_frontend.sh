#!/usr/bin/env bash

# This script updates setupProxy.js file with the public IP address of
# either of the host running in the public subnet
# or the load balancer routing traffic to and from the host deployed in the private subnet.

# Tests connection to the backend server leveraging "ping" and "telnet".

# Starts the frontend Plaid Quickstart service upon the update.

# Arguments:
# $1 - path to the directory hosting the cloned GitHub repository storing the Plaid source code
# $2 - public DNS of either the host running in the public subnet
#      or the load balancer routing traffic to and from the host deployed in the private subnet
# $3 - port number the backend service listens on (8000)

PLAID_HOME="$1"
BACKEND_DNS="$2"
BACKEND_PORT="$3"

for BACKEND_IP in $( dig +short "$BACKEND_DNS" )
do
    ping -c 1 "$BACKEND_IP" > /dev/null 2>&1
    if [[ $? -eq 0 ]]; then break; fi
done

frontend_home="$PLAID_HOME/frontend"
setup_proxy_file="$frontend_home/src/setupProxy.js"
sed -E -i '' -e "s~(^[[:space:]]*target:[[:space:]]*process.env.REACT_APP_API_HOST[[:space:]]*\|\|[[:space:]]*\'http://)([^:]*)(:[[:digit:]]+)~\1${BACKEND_IP}:${BACKEND_PORT}~" "$setup_proxy_file"
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
    "$test_connect" "$BACKEND_IP" "$BACKEND_PORT" > /dev/null 2>&1
    result=$?
    if [[ $result -ne 0 ]]; then sleep $pause_seconds; fi
    let attempts--
done    
rm -f "$test_connect"

tmux kill-session -t $PLAID_HOME 2> /dev/null
tmux new-session -d -s $PLAID_HOME 'npm start'
popd > /dev/null

