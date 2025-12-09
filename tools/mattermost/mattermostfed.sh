#!/bin/bash

# This is for Mattermost Org specific bash functions and settings
# This is set in the tmp/env.sh file as MATTERMOSTFED=TRUE

export MMCTL_URL="https://releases.mattermost.com/mmctl/${MMCTL_RELEASE_VERSION}/linux_amd64.tar"
export MATTERMOST_API_URL="https://federation.mattermost.com/api/v4"
export MATTERMOST_SITE_URL="https://federation.mattermost.com"

# # Versions
export MMCTL_RELEASE_VERSION="v11.1.0"
export MMCTL_PREVIOUS_VERSION="v11.1.0"


# ------------------
# Secret Functions
# ------------------
function _source_mattermost_functionality(){
    # This is for Mattermost Fed specific bash functions and settings
    if [ -z "$MATTERMOSTFED" ] || [ "$MATTERMOSTFED" != "TRUE" ]; then
        return
    fi
    echo -e "${GREEN}Mattermost Fed tools enabled.${NC}"
}

_source_mattermost_functionality