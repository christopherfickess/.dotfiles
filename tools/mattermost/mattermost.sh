#!/bin/bash

# This is for Mattermost Org specific bash functions and settings
if [ -z "$MATTERMOST" ] || [ "$MATTERMOST" != "TRUE" ]; then
    return
fi

# Versions
export MMCTL_RELEASE_VERSION="v11.1.0"
export MMCTL_PREVIOUS_VERSION="v11.1.0"

# URLs
export MMCTL_URL="https://releases.mattermost.com/mmctl/v11.1.0/linux_amd64.tar"
export MATTERMOST_API_URL="https://chat.mattermost.com/api/v4"
export MATTERMOST_SITE_URL="https://chat.mattermost.com"


# Clone Mattermost repo if it doesn't exist
if [ ! -d "$HOME/git/mattermost/mattermost" ]; then
    pushd $HOME/git/mattermost
        git clone https://github.com/mattermost/mattermost.git
    popd
fi

# Clone Mattermost Cloud repo if it doesn't exist
if [ ! -d "$HOME/git/mattermost/mattermost-cloud" ]; then
    pushd $HOME/git/mattermost
        git clone https://github.com/mattermost/mattermost-cloud.git
    popd
fi

# Clone Mattermost Cloud Monitoring repo if it doesn't exist
if [ ! -d "$HOME/git/mattermost/mattermost-cloud-monitoring" ]; then
    pushd $HOME/git/mattermost
        git clone https://github.com/mattermost/mattermost-cloud-monitoring.git
    popd
fi

# Clone Mattermost Operator repo if it doesn't exist
if [ ! -d "$HOME/git/mattermost/mattermost-operator" ]; then
    pushd $HOME/git/mattermost
        git clone https://github.com/mattermost/mattermost-operator.git
    popd
fi

# Create mattermost directory if it doesn't exist
if [ ! -d "$HOME/git/mattermost" ]; then
    mkdir -p $HOME/git/mattermost
fi

# Clone Mattermost mm-utils repo if it doesn't exist
if [ ! -d "$HOME/git/mattermost/mm-utils" ]; then
    pushd $HOME/git/mattermost
        git clone https://github.com/mattermost/mm-utils.git
        find $HOME/git/mattermost/mm-utils/scripts -type f -exec dos2unix {} +
    popd
fi

# Source Mattermost mm-utils scripts
if [ -d "$HOME/git/mattermost/mm-utils" ]; then
    for i in $HOME/git/mattermost/mm-utils/scripts/*.zsh; do
        source $i;
    done
fi

function mattermost_functions_help() {
    echo -e "${GREEN}Mattermost Functions:${NC}"

    echo -e "  mmctl                  ${GREEN}# Mattermost command line tool${NC}"
    echo -e "  update_mattermost_ctl  ${GREEN}# Updated Mattermost ctl Tool to latest version${NC}"

    # echo -e "  setup-mattermost-operator      ${GREEN}# Set up Mattermost Operator in your Kubernetes cluster${NC}"
    # echo -e "  deploy-mattermost-instance     ${GREEN}# Deploy a Mattermost instance using the Mattermost Operator${NC}"
    # echo -e "  delete-mattermost-instance     ${GREEN}# Delete the Mattermost instance from your Kubernetes cluster${NC}"
}

function update_mattermost_ctl() {
    echo -e "${GREEN}Updating Mattermost ctl Tool...${NC}"

    ls ~/bin/mmctl && sudo rm ~/bin/mmctl
    curl -vfsSL -O $MMCTL_URL > ~/bin/linux_amd64.tar

    sudo mv ~/bin/mmctl /tmp/mmctl_${MMCTL_PREVIOUS_VERSION}

    tar -xvf ~/bin/linux_amd64.tar -C ~/bin/
    rm ~/bin/linux_amd64.tar
    echo -e "${GREEN}Mattermost ctl Tool updated successfully.${NC}"
}
