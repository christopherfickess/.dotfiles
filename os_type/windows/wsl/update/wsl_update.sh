#!/bin/bash

function upgrade_wsl() {
    echo -e "${GREEN}Updating WSL configurations and scripts...${NC}"

    net session >/dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        echo "Running as root (admin)"
        wsl.exe --update
    else
        echo "Not running as root"
    fi

    

    # Add your upgrade commands here
    _upgrade_wsl_environment

    echo -e "${GREEN}WSL upgrade completed.${NC}"
}


# ------------------
# Secret Functions
# ------------------
function _upgrade_wsl_environment() {
    # Placeholder for future WSL environment upgrade logic
    echo -e "${GREEN}Checking for WSL environment updates...${NC}"
    
    wsl.exe sh -c "
    
    echo -e \"${GREEN}== Updating distribution packages ==${NC}\"
    sudo dnf upgrade --refresh -y

    echo -e \"${GREEN}== Updating Python tools ==${NC}\"
    python3 -m pip install --upgrade pip setuptools wheel

    echo -e \"${GREEN}== Updating AWS CLI if installed ==${NC}\"
    if command -v aws &>/dev/null; then
        pip3 install --upgrade awscli
    fi

    echo -e \"${GREEN}== Updating Teleport ==${NC}\"
    if command -v tctl &>/dev/null; then
        if [ -z \"$TELEPORT_VERSION\" ]; then
            echo -e \"${RED}TELEPORT_VERSION is not set. Cannot proceed with the update.${NC}\"
        fi

        if [ -d \"/home/$USERNAME/bin/teleport\" ]; then
            mv /home/$USERNAME/bin/teleport /home/$USERNAME/bin/teleport_backup_$(date +%Y%m%d_%H%M%S)
        fi

        sudo mkdir -p /home/$USERNAME/bin
        echo -e \"${MAGENTA}user name /home/$USERNAME ${TELEPORT_VERSION}...${NC}\"
        pushd /home/$USERNAME/bin >/dev/null
            curl -sO https://cdn.teleport.dev/teleport-$TELEPORT_VERSION-linux-amd64-bin.tar.gz
            tar -xzf teleport-$TELEPORT_VERSION-linux-amd64-bin.tar.gz
            cd teleport
            sudo ./install
        popd >/dev/null
        rm -rf /home/$USERNAME/bin/teleport-$TELEPORT_VERSION-linux-amd64-bin.tar.gz 
        rm -rf /home/$USERNAME/bin/teleport_backup_*
    fi

    echo -e \"${GREEN}== Updating kubectl ==${NC}\"
    if command -v kubectl &>/dev/null; then
        curl -sLO \"https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl\"
        sudo install -m 0755 kubectl /usr/local/bin/kubectl
        rm kubectl
    fi

    echo -e \"${GREEN}== Updating Minikube ==${NC}\"
    if command -v minikube &>/dev/null; then
        curl -sLO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
        sudo install minikube-linux-amd64 /usr/local/bin/minikube
        rm minikube-linux-amd64
    fi

    echo -e \"${GREEN}== Updating kubecolor ==${NC}\"
    if command -v go &>/dev/null; then
        go install github.com/hidetatz/kubecolor/cmd/kubecolor@latest
    fi

    echo -e \"${GREEN}== Updating Docker packages ==${NC}\"
    if command -v docker &>/dev/null; then
        sudo dnf update -y docker* || true
        sudo apt install --only-upgrade docker* -y 2>/dev/null || true
    fi
    "
}
