#!/bin/bash

# This is for Mattermost Fed specific bash functions and settings
if [ -z "$MATTERMOSTFED" ] || [ "$MATTERMOSTFED" != "TRUE" ]; then
    return
fi

