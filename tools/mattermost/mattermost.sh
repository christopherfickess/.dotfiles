#!/bin/bash

if [ "$MATTERMOST" != "TRUE" ]; then
    return
fi

# Versions
export MMCTL_RELEASE_VERSION="v11.1.0"
export MMCTL_PREVIOUS_VERSION="v11.1.0"

# URLs
export MMCTL_URL="https://releases.mattermost.com/mmctl/v11.1.0/linux_amd64.tar"
export MATTERMOST_API_URL="https://chat.mattermost.com/api/v4"
export MATTERMOST_SITE_URL="https://chat.mattermost.com"

function mattermost_functions_help() {
    echo -e "${GREEN}Mattermost Functions:${NC}"

    echo -e "  mmctl                  ${GREEN}# Mattermost command line tool${NC}"
    echo -e "  update_mattermost_ctl  ${GREEN}# Updated Mattermost ctl Tool to latest version${NC}"

    # echo -e "  setup-mattermost-operator      ${GREEN}# Set up Mattermost Operator in your Kubernetes cluster${NC}"
    # echo -e "  deploy-mattermost-instance     ${GREEN}# Deploy a Mattermost instance using the Mattermost Operator${NC}"
    # echo -e "  delete-mattermost-instance     ${GREEN}# Delete the Mattermost instance from your Kubernetes cluster${NC}"
}

function _setup_mattermost_mmutils() {
    # Source Mattermost mm-utils scripts
    if [ -f "$HOME/.dotfiles/tools/mattermost/mattermost.sh" ]; then 
        
        if [ ! -d "$HOME/git/mattermost/mm-utils" ]; then
            mkdir -p $HOME/git/mattermost

            pushd $HOME/git/mattermost
                git clone https://github.com/mattermost/mm-utils.git
                find $HOME/git/mattermost/mm-utils/scripts -type f -exec dos2unix {} +
            popd
        fi
    fi

    if [ -d "$HOME/git/mattermost/mm-utils" ]; then
        for i in $HOME/git/mattermost/mm-utils/scripts/*.zsh; do
            source $i;
        done
    fi
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


# Source Mattermost mm-utils scripts
if [ -d "$HOME/git/mattermost/mm-utils" ]; then
    for i in $HOME/git/mattermost/mm-utils/scripts/*.zsh; do
        source $i;
    done
fi
