#!/bin/bash

# This is for Mattermost Org specific bash functions and settings
# This is set in the tmp/env.sh file as MATTERMOSTFED=TRUE

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