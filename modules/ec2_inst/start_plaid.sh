#!/usr/bin/env bash

# eval "$(jq -r '@sh "SSH_ALIAS=\(.ssh_alias) PLAID_HOME=\(.plaid_home) PUBLIC_IP=\(.public_ip) PLAID_CLIENT_ID=\(.plaid_client_id) PLAID_SECRET=\(.plaid_secret)"')"

SSH_ALIAS="$1"
PLAID_HOME="$2"
PUBLIC_IP="$3"
PLAID_CLIENT_ID="$4"
PLAID_SECRET="$5"
PLAID_ENV="sandbox"
PLAID_PRODUCTS="auth,transactions,identity"

backend_home="$PLAID_HOME/frontend/src"

if [[ -d "$PLAID_HOME" ]]; then rm -rf "$PLAID_HOME"; fi
git clone https://github.com/plaid/quickstart.git "$PLAID_HOME"
pushd "$PLAID_HOME"
cp .env.example .env
sed -E -i -e "s~(PLAID_CLIENT_ID=)([[:print:]]*)~\1$PLAID_CLIENT_ID~; \
              s~(PLAID_SECRET=)([[:print:]]*)~\1$PLAID_SECRET~; \
              s~(PLAID_ENV=)([[:print:]]*)~\1$PLAID_ENV~; \
              s~(PLAID_PRODUCTS=)([[:print:]]*)~\1$PLAID_PRODUCTS~" \
              .env
popd

remote_spec_file="$backend_home/setupProxy.js"
sed -E -i -e "s~(^[[:space:]]*target:[[:space:]]*process.env.REACT_APP_API_HOST[[:space:]]*\|\|[[:space:]]*\'http://)([^:]*)(:8000)~\1$PUBLIC_IP\3~" "$remote_spec_file"

scp "$PLAID_HOME/.env" "${SSH_ALIAS}:~/$PLAID_HOME"
scp "$remote_spec_file" "${SSH_ALIAS}:~/$backend_home"
ssh "$SSH_ALIAS" "cd $PLAID_HOME/node; npm install; npm audit fix --force; tmux new-session -d -s $PLAID_HOME 'npm start'"
pushd "$PLAID_HOME/frontend" > /dev/null
npm install
tmux kill-session -t $PLAID_HOME 2> /dev/null
tmux new-session -d -s $PLAID_HOME 'npm start'
popd > /dev/null

# FOOBAZ="started"
# jq -n --arg foobaz "$FOOBAZ" '{"foobaz":$foobaz}'
# jq -n --arg plaid_started "$PLAID_STARTED" '{"plaid_started":$plaid_started}'


