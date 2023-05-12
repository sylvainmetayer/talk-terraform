#!/usr/bin/env bash

export AWS_PROFILE=demo_tf
cd demo
BROWSER=echo aws sso login
./delete.sh

echo "You should be good to go :)"

echo "Ensure workspace is clean by closing all tabs"
code $HOME/Documents/git/terraform/demo
