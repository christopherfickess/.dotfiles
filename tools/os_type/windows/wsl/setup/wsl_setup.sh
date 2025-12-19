#!/bin/bash

# WSL Setup Script
function setup_wsl() {
    echo -e "${GREEN}Running pre-WSL checks...${NC}"
    echo

    # Example check: verify that a WSL distro exists
    if ! command -v wsl.exe > /dev/null; then
        echo -e "   ${RED}WSL not found on this system.${NC}"
        return 1
    fi
    
    echo
    _setup_wsl_init
}

# ------------------
# Secret Functions
# ------------------

function _setup_wsl_init(){
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
        _setup_wsl_tools
    fi
}

function _setup_wsl_tools() {
    echo -e "${GREEN}Setting up WSL tools...${NC}"
    
    wsl.exe sh -c "
        if [ -f /mnt/c/Users/${USERNAME}/.bashrc ]; then
            cat /mnt/c/Users/${USERNAME}/.bashrc >> ~/.bashrc
        fi
        if [ -d /mnt/c/Users/${USERNAME}/.dotfiles ]; then
            ln -sf /mnt/c/Users/${USERNAME}/.dotfiles ~/
        fi
        if [ -d /mnt/c/Users/${USERNAME}/git ]; then
            ln -sf /mnt/c/Users/${USERNAME}/git ~/
        fi
        if [ -d /mnt/c/Users/${USERNAME}/.aws ]; then
            ln -sf /mnt/c/Users/${USERNAME}/.aws ~/
        fi
        if [ -d /mnt/c/Users/${USERNAME}/.kube ]; then
            ln -sf /mnt/c/Users/${USERNAME}/.kube ~/
        fi
        if [ -d /mnt/c/Users/${USERNAME}/.minikube ]; then
            ln -sf /mnt/c/Users/${USERNAME}/.minikube ~/
        fi
        if [ -d /mnt/c/Users/${USERNAME}/.docker ]; then
            ln -sf /mnt/c/Users/${USERNAME}/.docker ~/
        fi
        if [ -d /mnt/c/Users/${USERNAME}/.ssh ]; then
            ln -sf /mnt/c/Users/${USERNAME}/.ssh ~/
        fi
        if [ -d /mnt/c/Users/${USERNAME}/.tsh ]; then
            ln -sf /mnt/c/Users/${USERNAME}/.tsh ~/
        fi

        echo -e \"${GREEN}Setting up Teleport...${NC}\"
        
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
            dstat \
            envsubst \
            fzf \
            gcc \
            git \
            golang-go \
            helm \
            htop \
            iftop \
            iotop \
            jq \
            k9s \
            kubectl \
            nano \
            nmap \
            openssl \
            pip \
            sysstat \
            tree \
            unzip \
            vim \
            wget \
            yamllint \
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


# if wsl fedora VM exists, skip setup (can be any wsl distro)
if ! wsl.exe -l -v | iconv -f UTF-16LE -t UTF-8 | sed '1d' | grep -q "Running\|Stopped"; then
    echo -e "       ${CYAN}WSL distribution not found. Setting up WSL...${NC}"
    setup_wsl
else 
    echo -e "       ${CYAN}WSL distribution already exists. Skipping WSL setup.${NC}"
fi