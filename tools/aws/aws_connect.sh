#!/bin/bash

# TELEPORT_LOGIN is set in the tmp/env.sh file
    # e.g., mattermost.com:443
function connect_aws_teleport() {
    if command -v tsh &> /dev/null; then
        echo "Connecting to AWS Teleport..."
        tsh login --proxy=${TELEPORT_LOGIN} teleport-main
    else
        echo "Teleport CLI (tsh) is not installed. Please install it to connect."
    fi
}