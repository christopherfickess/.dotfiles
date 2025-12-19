#!/bin/bash

# TELEPORT_LOGIN is set in the tmp/env.sh file
    # e.g., mattermost.com:443

function tshl() {
    if command -v tsh &> /dev/null; then
        echo "Logging into Teleport proxy at ${TELEPORT_LOGIN}..."
        tsh login --proxy "${TELEPORT_LOGIN}" --auth=microsoft
    else
        echo "Teleport CLI (tsh) is not installed. Please install it to log in."
    fi
}
