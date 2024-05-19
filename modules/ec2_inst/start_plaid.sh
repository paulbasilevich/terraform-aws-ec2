#!/usr/bin/env bash

ssh_alias="$1"
plaid_home="$2"
public_ip="$3"

backend_home="$plaid_home/frontend/src"

if [[ -d "$plaid_home" ]]; then rm -rf "$plaid_home"; fi
git clone https://github.com/plaid/quickstart.git "$plaid_home"
pushd "$plaid_home" > /dev/null
cp .env.example .env
plaid_env="sandbox"
plaid_products="auth,transactions,identity"
plaid_client_id="$( echo "$PLAID_CLIENT_ID" )"
plaid_secret="$( echo "$PLAID_SECRET" )"
sed -E -i -e "s~(PLAID_CLIENT_ID=)([[:print:]]*)~\1$plaid_client_id~; \
              s~(PLAID_SECRET=)([[:print:]]*)~\1$plaid_secret~; \
              s~(PLAID_ENV=)([[:print:]]*)~\1$plaid_env~; \
              s~(PLAID_PRODUCTS=)([[:print:]]*)~\1$plaid_products~" \
              .env
popd > /dev/null

remote_spec_file="$backend_home/setupProxy.js"
sed -E -i -e "s~(^[[:space:]]*target:[[:space:]]*process.env.REACT_APP_API_HOST[[:space:]]*\|\|[[:space:]]*\'http://)([^:]*)(:8000)~\1$public_ip\3~" "$remote_spec_file"

scp "$plaid_home/.env" "${ssh_alias}:~/$plaid_home"
scp "$backend_home/setupProxy.js" "${ssh_alias}:~/$backend_home"
ssh "$ssh_alias" "cd $plaid_home/node; npm install; npm audit fix --force; tmux new-session -d -s $plaid_home 'npm start'"
pushd "$plaid_home/frontend" > /dev/null
npm install
tmux kill-session -t $plaid_home 2> /dev/null
tmux new-session -d -s $plaid_home 'npm start'
popd > /dev/null
