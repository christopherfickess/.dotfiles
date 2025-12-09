#!/bin/bash

function destroy_wsl_distro() {
    if [ ! -z "$1" ]; then
        echo -e "${GREEN}Enter the name of the distribution to unregister${NC}"
        read -p "(delete): " DISTRO_NAME        
    else
        DISTRO_NAME="FedoraLinux-43" 
    fi

    echo -e "${MAGENTA}Unregistering (deleting) WSL distribution: $DISTRO_NAME${NC}"
    echo
    wsl.exe -t "$DISTRO_NAME"
    wsl.exe --unregister "$DISTRO_NAME"
    echo
    echo -e "${GREEN}Distribution $DISTRO_NAME has been unregistered.${NC}"
}

function setup_wsl() {
    echo -e "${GREEN}Running pre-WSL checks...${NC}"
    echo

    # Example check: verify that a WSL distro exists
    if ! command -v wsl.exe > /dev/null; then
        echo -e "   ${RED}WSL not found on this system.${NC}"
        return 1
    fi

    _set_wsl_setup_process
    
    echo
    echo -e "Launching WSL..."
    wsl.exe "$@"
}

function start_minikube_wsl() {
    echo -e "${GREEN}Starting Minikube in WSL...${NC}"

    if ! command -v minikube > /dev/null; then
        echo -e "${RED}Minikube not found. Please install it first.${NC}"
        exit 1
    fi
    if ! command -v docker > /dev/null; then
        echo -e "${RED}Docker not found. Please install it first.${NC}"
        exit 1
    fi    
    minikube start --driver=docker
    minikube status
    echo -e "${GREEN}Minikube started successfully.${NC}"
}


# ------------------
# Secret Functions
# ------------------
function _install_wsl_tools() {
    echo -e "${GREEN}Installing WSL tools...${NC}"
    
    wsl.exe sh -c "
        cat /mnt/c/Users/${USERNAME}/.bashrc >> ~/.bashrc
        ln -sf /mnt/c/Users/${USERNAME}/.dotfiles ~/
        ln -sf /mnt/c/Users/${USERNAME}/git ~/

        
        echo -e \"${GREEN}Installing Teleport...${NC}\"
        
        mkdir -p /home/$USERNAME/bin
        pushd /home/$USERNAME/bin;
            curl -O https://cdn.teleport.dev/teleport-${TELEPORT_VERSION}-linux-amd64-bin.tar.gz
            tar -xzf teleport-${TELEPORT_VERSION}-linux-amd64-bin.tar.gz
            cd teleport
            sudo ./install
        popd

        sudo dnf update -y
        sudo dnf install -y --skip-unavailable \
            awscli \
            containers-common \
            curl \
            docker \
            dos2unix \
            git \
            golang-go \
            helm \
            jq \
            k9s \
            kubectl \
            nano \
            pip \
            unzip \
            vim \
            wget \
            yq \
            zsh
            
        go install github.com/hidetatz/kubecolor/cmd/kubecolor@latest

        echo -e \"${GREEN}Configuring Docker User...${NC}\"
        sudo usermod -aG docker $USER
        newgrp docker
        docker ps
        echo -e \"${GREEN}Docker user configured.${NC}\"
        echo -e \"${GREEN}Installing Minikube...${NC}\"
        curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
        sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64

        find ~/.dotfiles -type f -exec dos2unix {} +

        source ~/.bashrc
        echo -e \"${GREEN}WSL setup process completed.${NC}\"
    "

    echo -e "${GREEN}WSL tools installation completed.${NC}"
}

function _remove_line_endings() {
    # Useful if there are windows line ending issues
    wsl.exe sh -c "
        dos2unix ~/.dotfiles/.bashrc \
            ~/.dotfiles/.bash_aliases \
            ~/.dotfiles/.bash_functions \
            ~/.dotfiles/aws/kubernetes_functions.sh \
            ~/.dotfiles/aws/aws_functions.sh \
            ~/.dotfiles/windows/.bashrc \
            ~/.dotfiles/windows/.bash_functions
    "
}

function _setup_wsl_environment() {
    
    _install_wsl_tools

    if [ "$MATTERMOST" = "TRUE" ]; then _setup_mattermost_mmutils;  fi
}

function _set_wsl_setup_process(){
    WIN_DOTFILES_DIR="$HOME/.dotfiles"

    # Target Fedora distro
    FEDORA_DISTRO="FedoraLinux-43"    
    
    if wsl.exe -l -v | iconv -f UTF-16LE -t UTF-8 | sed 1,1d | awk '{print $2}' | grep -Fx "$FEDORA_DISTRO"; then
        echo -e "${CYAN}$FEDORA_DISTRO already installed.${NC}"
    else
        echo -e "${MAGENTA}$FEDORA_DISTRO not found. Installing...${NC}"
        wsl.exe --install -d "$FEDORA_DISTRO"
        
        wsl.exe --set-default $FEDORA_DISTRO

        DEFAULT_DISTRO=$(wsl.exe -l -v | grep "Default" | awk '{print $1}' | tr -d '\r')

        echo -e "${GREEN}Setting up WSL environment...${NC}"  
        _setup_wsl_environment
    fi
}

