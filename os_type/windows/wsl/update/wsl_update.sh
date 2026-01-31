#!/bin/bash

function update_wsl() {
    echo -e "${GREEN}Updating WSL configurations and scripts...${NC}"

    net session >/dev/null 2>&1
    echo

    if [[ "$__OS_TYPE" == "wsl" ]]; then
        echo -e "${GREEN}Detected WSL environment. Upgrading Linux environment...${NC}"
    
        __update_wsl_environment__
    elif [[ $? -eq 0 ]]; then
        echo -e "Running as ${MAGENTA}root (admin)${NC}"
        echo
        echo -e "      ${MAGENTA}Checking for WSL updates...${NC}"
        wsl.exe --update
        echo
    else
        echo "Not running as root"
    fi
}


# ------------------
# Secret Functions
# ------------------
function __update_wsl_environment__() {
    # Placeholder for future WSL environment upgrade logic
    
    echo $TELEPORT_VERSION
    # Figure this out later
    # __safe_link__ "$WIN_HOME/.dotfiles"     "$HOME/.dotfiles"

    echo -e "${GREEN}== Updating distribution packages ==${NC}"
    sudo dnf upgrade --refresh -y || sudo yum upgrade -y || (sudo apt update && sudo apt upgrade -y)
    echo

    echo -e "${GREEN}== Updating Python tools ==${NC}"
    python3 -m pip install --upgrade pip setuptools wheel

    echo -e "${GREEN}== Updating AWS CLI if installed ==${NC}"
    if command -v aws &>/dev/null; then
        pip3 install --upgrade awscli
        echo
    fi

    echo -e "${GREEN}== Updating Teleport (Not Running Until Tested) ==${NC}"
    echo
    # if command -v tctl &>/dev/null; then
    #     if [ -z "$TELEPORT_VERSION" ]; then
    #         echo -e "${RED}TELEPORT_VERSION is not set. Cannot proceed with the update.${NC}"
    #     fi

    #     if [ -d "/home/$USERNAME/bin/teleport" ]; then
    #         mv /home/$USERNAME/bin/teleport /home/$USERNAME/bin/teleport_backup_$(date +%Y%m%d_%H%M%S)
    #     fi

    #     sudo mkdir -p /home/$USERNAME/bin
    #     echo -e "${MAGENTA}user name /home/$USERNAME ${TELEPORT_VERSION}...${NC}"
    #     pushd /home/$USERNAME/bin >/dev/null
    #         curl -sO https://cdn.teleport.dev/teleport-$TELEPORT_VERSION-linux-amd64-bin.tar.gz
    #         tar -xzf teleport-$TELEPORT_VERSION-linux-amd64-bin.tar.gz
    #         cd teleport
    #         sudo ./install
    #     popd >/dev/null
    #     rm -rf /home/$USERNAME/bin/teleport-$TELEPORT_VERSION-linux-amd64-bin.tar.gz 
    #     rm -rf /home/$USERNAME/bin/teleport_backup_*
    #     echo
    # fi

    if command -v kubectl &>/dev/null; then
        echo -e "${GREEN}== Updating kubectl ==${NC}"

        curl -sLO "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        sudo install -m 0755 kubectl /usr/local/bin/kubectl
        rm kubectl
        echo
    fi

    if command -v minikube &>/dev/null; then
        echo -e "${GREEN}== Updating Minikube ==${NC}"
        curl -sLO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
        sudo install minikube-linux-amd64 /usr/local/bin/minikube
        rm minikube-linux-amd64
        echo
    fi

    if command -v go &>/dev/null; then
        echo -e "${GREEN}== Updating kubecolor ==${NC}"
        go install github.com/hidetatz/kubecolor/cmd/kubecolor@latest
        echo
    fi

    if command -v docker &>/dev/null; then
        echo -e "${GREEN}== Updating Docker packages ==${NC}"   
        sudo dnf update -y docker* || sudo apt install --only-upgrade docker* -y 2>/dev/null
        echo
    fi
    echo -e "${GREEN}WSL environment update completed.${NC}"
}


## Figure out how to export variable into WSL environment
function __safe_link__() {
    local src="$1"
    local dest="$2"

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
            return 0
        else
            echo "Skipping $dest (already exists)"
            return 0
        fi
    fi

    ln -s "$src" "$dest"
}


function __get_wsl_version__() {
    wsl.exe --version 2>/dev/null | \
        iconv -f UTF-16LE -t UTF-8 | \
        awk -F: '/WSL version/ { gsub(/^[ \t]+/, "", $2); print $2 }'
}
