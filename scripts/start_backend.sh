#!/usr/bin/env bash

# This script clones the source code of Plaid Quickstart backend service from GitHub,
# updates it in situ with the user credentials along with the environment and product settings,
# and starts the service in a tmux session.

# Arguments:
# $1 - the value of count.index: 0 - pertains public network; 1 - private network
# $2 - the value the above $1 has to match (i.e. "public" or "private" association)
#      for the mainstream logic to actually run
# $3 - "Host" name of the target EC2 instance in the context of ~/.ssh/config file
# $4 - the value of PLAID_CLIENT_ID environment variable
# $5 - the value of PLAID_SECRET environment variable

this_index="$1"
that_index="$(( $2 - 1 ))"

if [[ $this_index -eq $that_index ]]
then
SSH_ALIAS="$3"
PLAID_CLIENT_ID="$4"
PLAID_SECRET="$5"

# For access to the home directory name at destroy time:
PLAID_HOME="$SSH_ALIAS"

PLAID_ENV="sandbox"
PLAID_PRODUCTS="auth,transactions,identity"

if [[ -d "$PLAID_HOME" ]]; then rm -rf "$PLAID_HOME"; fi
git clone https://github.com/plaid/quickstart.git "$PLAID_HOME" > /dev/null
pushd "$PLAID_HOME" > /dev/null
cp .env.example .env
sed -E -i '' -e "s~(PLAID_CLIENT_ID=)([[:print:]]*)~\1$PLAID_CLIENT_ID~; \
                 s~(PLAID_SECRET=)([[:print:]]*)~\1$PLAID_SECRET~; \
                 s~(PLAID_ENV=)([[:print:]]*)~\1$PLAID_ENV~; \
                 s~(PLAID_PRODUCTS=)([[:print:]]*)~\1$PLAID_PRODUCTS~" \
                .env
popd > /dev/null

scp "$PLAID_HOME/.env" "${SSH_ALIAS}:~/$PLAID_HOME"
ssh "$SSH_ALIAS" << EOT
cd $PLAID_HOME/node
npm install
npm audit fix --force
tmux new-session -d -s $PLAID_HOME 'npm start'
EOT
fi
