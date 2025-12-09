#!/bin/bash

function update_wsl_environment() {
    echo -e "${GREEN}Updating WSL configurations and scripts...${NC}"
    wsl.exe --update

    # Add your update commands here
    _update_wsl_environment

    echo -e "${GREEN}WSL update completed.${NC}"
}


# ------------------
# Secret Functions
# ------------------
function _update_wsl_environment() {
    # Placeholder for future WSL environment update logic
    echo -e "${GREEN}Checking for WSL environment updates...${NC}"
    
    wsl.exe sh -c '
    GREEN="\033[0;32m"
    NC="\033[0m"
    echo -e "\${GREEN}== Updating distribution packages =="\${NC}
    
    sudo dnf upgrade --refresh -y

    echo -e "\${GREEN}== Updating Python tools =="\${NC}
    python3 -m pip install --upgrade pip setuptools wheel

    echo -e "\${GREEN}== Updating AWS CLI if installed =="\${NC}
    if command -v aws &>/dev/null; then
        pip3 install --upgrade awscli
    fi

    echo -e "\${GREEN}== Updating Teleport =="\${NC}
    if command -v tctl &>/dev/null; then
        mkdir -p $HOME/bin/update-tmp
        pushd $HOME/bin/update-tmp >/dev/null
            curl -sO https://cdn.teleport.dev/teleport-v18.4.0-linux-amd64-bin.tar.gz
            tar -xzf teleport-v18.4.0-linux-amd64-bin.tar.gz
            cd teleport
            sudo ./install
        popd >/dev/null
        rm -rf $HOME/bin/update-tmp
    fi

    echo -e "\${GREEN}== Updating kubectl =="\${NC}
    if command -v kubectl &>/dev/null; then
        curl -sLO "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        sudo install -m 0755 kubectl /usr/local/bin/kubectl
        rm kubectl
    fi

    echo -e "\${GREEN}== Updating Minikube =="\${NC}
    if command -v minikube &>/dev/null; then
        curl -sLO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
        sudo install minikube-linux-amd64 /usr/local/bin/minikube
        rm minikube-linux-amd64
    fi

    echo -e "\${GREEN}== Updating kubecolor =="\${NC}
    if command -v go &>/dev/null; then
        go install github.com/hidetatz/kubecolor/cmd/kubecolor@latest
    fi

    echo -e "\${GREEN}== Updating Docker packages =="\${NC}
    if command -v docker &>/dev/null; then
        sudo dnf update -y docker* || true
        sudo apt install --only-upgrade docker* -y 2>/dev/null || true
    fi
    '
}