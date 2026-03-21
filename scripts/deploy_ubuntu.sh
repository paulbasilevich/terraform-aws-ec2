#!/usr/bin/env bash

# This script prepares the environment for Plaid Quickstart backend service
# to run on Ubuntu operating platform.

# Usage: deploy_ubuntu.sh <path to local directory where the Plaid source code needs to be>

workdir="$1"
sudo apt-get update
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install nodejs -y
echo -n "Node: "
node --version
echo -n "Npm :"
npm --version
sleep 10

dependencies=(
    tmux
    git
    vim
)

for dep in ${dependencies[@]}; do
    if [[ -z $( which $dep ) ]]; then
        sudo apt-get install $dep -y
    fi
done

git clone https://github.com/plaid/quickstart.git ${workdir}
