#!/bin/bash

# This is for Mattermost Org specific bash functions and settings
if [ -z "$MATTERMOST" ] || [ "$MATTERMOST" != "TRUE" ]; then
    return
fi

# # Versions
export MMCTL_RELEASE_VERSION="v11.1.0"
export MMCTL_PREVIOUS_VERSION="v11.1.0"

# URLs
export MMCTL_URL="https://releases.mattermost.com/mmctl/${MMCTL_RELEASE_VERSION}/linux_amd64.tar"
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

################################################
#   TP.AUTH Bug here - breaks git autocomplete #
################################################
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
    if [ -z "$ISWINDOWS" ] || [ "$ISWINDOWS" != "TRUE" ]; then
        echo -e "${RED}This function is only supported on Windows systems.${NC}"
        return 1
    elif [ -z "$MMCTL_PREVIOUS_VERSION" ]; then
        echo -e "${RED}MMCTL_PREVIOUS_VERSION is not set. Cannot proceed with the update.${NC}"
        return 1
    elif [ -z "$MMCTL_URL" ]; then
        echo -e "${RED}MMCTL_URL is not set. Cannot proceed with the update.${NC}"
        return 1
    elif [ -z "$MMCTL_RELEASE_VERSION" ]; then
        echo -e "${RED}MMCTL_RELEASE_VERSION is not set. Cannot proceed with the update.${NC}"
        return 1
    fi

    echo -e "${GREEN}Updating Mattermost ctl Tool...${NC}"
    pushd $HOME/bin;
        curl -vfsSL -O $MMCTL_URL > "${HOME}/bin/linux_amd64.tar" \
            && echo -e "${GREEN}Downloaded mmctl version ${MMCTL_RELEASE_VERSION}${NC}" || {
            echo -e "${RED}Failed to download mmctl from ${MMCTL_URL}${NC}"
            return 1
        };
    popd
    mkdir -p ${HOME}/tmp;

    echo -e "${MAGENTA}Backing up${NC} previous mmctl version to tmp folder..."
    mv ${HOME}/bin/mmctl ${HOME}/tmp/mmctl_${MMCTL_PREVIOUS_VERSION} || \
        echo -e "${YELLOW}    No previous mmctl version found to back up.${NC}";

    echo -e "${MAGENTA}Extracting and installing${NC} the new mmctl version..."
    tar -xvf ${HOME}/bin/linux_amd64.tar -C ${HOME}/bin/

    rm ${HOME}/bin/linux_amd64.tar
    echo -e "    Mattermost ctl Tool ${GREEN}updated successfully.${NC}"
}

function _check_mattermost_ctl() {
    if ! command -v mmctl &> /dev/null; then
        echo -e "${RED}mmctl could not be found. Please install it first.${NC}"
        return 1
    else
        echo -e "${CYAN}     mmctl is installed.${NC}"
    fi
} 

_check_mattermost_ctl || update_mattermost_ctl