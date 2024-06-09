#!/usr/bin/env bash

# This script prepares the environment for Plaid Quickstart service
# on the backend for Ubuntu operating platform

workdir="$1"
sudo apt-get update
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install nodejs -y
echo Node
node --version
echo Npm
npm --version
sleep 10
git clone https://github.com/plaid/quickstart.git ${workdir}
