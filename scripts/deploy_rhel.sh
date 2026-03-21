#!/usr/bin/env bash

# This script prepares the environment for Plaid Quickstart backend service
# to run on RHEL or Amazon Linux 2023 operating platform.
#
# Usage: deploy_rhel.sh <path to local directory where the Plaid source code needs to be>

workdir="$1"
sudo yum update -y
curl -sL https://rpm.nodesource.com/setup_22.x | sudo -E bash -
sudo yum install -y nsolid
echo Node
node --version
echo Npm
npm --version
sleep 10
sudo yum install -y tmux
sudo yum install -y git
git --version
git clone https://github.com/plaid/quickstart.git "${workdir}"
