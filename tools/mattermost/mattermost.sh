#!/bin/bash

# This is for Mattermost Org specific bash functions and settings
# This is set in the tmp/env.sh file as MATTERMOST=TRUE


function clone_mattermost_repo() {
    # if [ -z "$MATTERMOST_REPO_URL" ]; then
    #     echo -e "${RED}MATTERMOST_REPO_URL is not set. Cannot clone repository.${NC}"
    #     return 1
    # fi

    # Create mattermost directory if it doesn't exist
    if [ ! -d "$HOME/git/mattermost" ]; then
        echo -e "${GREEN}Creating mattermost directory...${NC}"
        mkdir -p $HOME/git/mattermost
    fi

    # Clone Mattermost repo if it doesn't exist
    if [ ! -d "$HOME/git/mattermost/mattermost" ]; then
        echo -e "${GREEN}Setting up Mattermost repo...${NC}"
        pushd $HOME/git/mattermost
            git clone https://github.com/mattermost/mattermost.git
        popd
    fi

    # Clone Mattermost Cloud repo if it doesn't exist
    if [ ! -d "$HOME/git/mattermost/mattermost-cloud" ]; then
        echo -e "${GREEN}Setting up Mattermost Cloud repo...${NC}"
        pushd $HOME/git/mattermost
            git clone https://github.com/mattermost/mattermost-cloud.git
        popd
    fi

    # Clone Mattermost Cloud Monitoring repo if it doesn't exist
    if [ ! -d "$HOME/git/mattermost/mattermost-cloud-monitoring" ]; then
        echo -e "${GREEN}Setting up Mattermost Cloud Monitoring repo...${NC}"
        pushd $HOME/git/mattermost
            git clone https://github.com/mattermost/mattermost-cloud-monitoring.git
        popd
    fi

    # Clone Mattermost Operator repo if it doesn't exist
    if [ ! -d "$HOME/git/mattermost/mattermost-operator" ]; then
        echo -e "${GREEN}Setting up Mattermost Operator repo...${NC}"
        pushd $HOME/git/mattermost
            git clone https://github.com/mattermost/mattermost-operator.git
        popd
    fi

    # Clone Mattermost mm-utils repo if it doesn't exist
    if [ ! -d "$HOME/git/mattermost/mm-utils" ]; then
        echo -e "${GREEN}Setting up Mattermost mm-utils repo...${NC}"
        pushd $HOME/git/mattermost
            git clone https://github.com/mattermost/mm-utils.git
            find $HOME/git/mattermost/mm-utils/scripts -type f -exec dos2unix {} +
        popd
    fi
}

# URLs
function mattermost_functions_help() {
    echo -e "${GREEN}Mattermost Functions:${NC}"

    echo -e "  mmctl                  ${GREEN}# Mattermost command line tool${NC}"
    echo -e "  update_mattermost_ctl  ${GREEN}# Updated Mattermost ctl Tool to latest version${NC}"

    # echo -e "  setup-mattermost-operator      ${GREEN}# Set up Mattermost Operator in your Kubernetes cluster${NC}"
    # echo -e "  deploy-mattermost-instance     ${GREEN}# Deploy a Mattermost instance using the Mattermost Operator${NC}"
    # echo -e "  delete-mattermost-instance     ${GREEN}# Delete the Mattermost instance from your Kubernetes cluster${NC}"
}

function mmctl() {
    if ! command -v mmctl &> /dev/null; then
        echo -e "${RED}mmctl could not be found. Please install it first.${NC}"
        update_mattermost_ctl
        return 1
    else
        echo -e "${CYAN}     mmctl is installed.${NC}"
    fi
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


# ------------------
# Secret Functions
# ------------------
function _source_mattermost_functionality() {
    if [ -z "$MATTERMOST" ] || [ "$MATTERMOST" != "TRUE" ]; then
        return
    else
        echo -e "${GREEN}   Mattermost tools enabled.${NC}"

        clone_mattermost_repo
    fi

    ################################################
    #   TP.AUTH Bug here - breaks git autocomplete #
    ################################################
    if [ -n "$ZSH_VERSION" ]; then
        if [ -d "$HOME/git/mattermost/mm-utils" ]; then
            for i in $HOME/git/mattermost/mm-utils/scripts/*.zsh; do
                source $i;
            done
        fi
    fi

    if [ -f "$HOME/.dotfiles/tools/mattermost/users.sh" ] && [ "$MATTERMOST" = "TRUE" ]; then  source "$HOME/.dotfiles/tools/mattermost/users.sh"; fi
}

_source_mattermost_functionality