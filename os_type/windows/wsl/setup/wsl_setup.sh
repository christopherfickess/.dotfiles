#!/bin/bash

function log() { echo -e "${GREEN}[INFO]${NC} $*"; }
function warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
function err() { echo -e "${RED}[ERROR]${NC} $*"; }

# WSL Setup Script
function setup_wsl() {
    if [[ -z "${1}" ]]; then
        echo -e "$MAGENTA setup_wsl \${1} not set distro set to ${__distro_type__}"
    fi

    __distro_type__="${1:-FedoraLinux-43}"

    echo -e "${GREEN}Running pre-WSL checks...${NC}"
    echo

    # Example check: verify that a WSL distro exists
    if ! command -v wsl.exe > /dev/null; then
        echo -e "   ${RED}WSL not found on this system.${NC}"
        return 1
    fi
    
    echo
    __check_wsl__
    __install_or_update_wsl__
    __ensure_distro__
    __post_install_wsl_tools__ 
}

# ------------------
# Secret Functions
# ------------------
function __check_wsl__() {
    if ! command -v wsl.exe &>/dev/null; then
        echo -e "${RED}[ERROR]${NC}WSL not found. Please enable WSL and try again."
        exit 1
    fi
}

function __install_or_update_wsl__() {
    if ! wsl.exe --update; then
        echo -e "${YELLOW}[WARN]WSL update failed. Trying web-download..."
        wsl.exe --install --web-download
    fi
}

function __ensure_distro__() {

    __check_distros__=$(wsl.exe -l 2>/dev/null \
    | iconv -f UTF-16LE -t UTF-8 \
    | tr -d '\0' \
    | tail -n +2 \
    | sed -E 's/^[* ]+//; s/ \(Default\)//; s/[[:space:]]+$//' \
    | tr '\r' '\n')

    echo "Installed __check_distros__:"
    echo "$__check_distros__"

    # Check if our distro exists
    if echo "$__check_distros__" | grep -qx "$__distro_type__"; then
        echo "$__distro_type__ already installed"
        return 1
    else
        echo "Installing $__distro_type__..."
        wsl.exe --install -d "$__distro_type__"
        echo "Installation started. Reboot may be required."
        return
    fi

    echo -e "${RED}[ERROR]${NC}Setting $__distro_type__ as default..."
    wsl.exe --set-default "$__distro_type__"
}

function __post_install_wsl_tools__() {
    echo -e "${GREEN}Setting up WSL tools...${NC}"
    
    # wsl.exe -e env TELEPORT_VERSION="$TELEPORT_VERSION" sh -lc '
    wsl.exe sh -c "
        if [ -f /mnt/c/Users/${USERNAME}/.bashrc ]; then
            cat /mnt/c/Users/${USERNAME}/.bashrc >> ~/.bashrc
        fi
        if [ -d /mnt/c/Users/${USERNAME}/.dotfiles ]; then
            ln -sf /mnt/c/Users/${USERNAME}/.dotfiles ~/
        fi
        if [ -f /mnt/c/Users/${USERNAME}/.gitconfig ]; then
            ln -sf /mnt/c/Users/${USERNAME}/.gitconfig ~/.gitconfig
        fi
        if [ -f /mnt/c/Users/${USERNAME}/.git-credentials ]; then
            ln -sf /mnt/c/Users/${USERNAME}/.git-credentials ~/.git-credentials
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

        curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "session-manager-plugin.rpm"
        curl -s https://fluxcd.io/install.sh | sudo bash
        
        sudo dnf update -y
        sudo dnf install -y --skip-unavailable \
            awscli \
            containers-common \
            curl \
            dnf-plugins-core \
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
            session-manager-plugin.rpm \
            sysstat \
            tree \
            unzip \
            vim \
            wget \
            yamllint \
            yq \
            zsh

            
        rm -f session-manager-plugin.rpm
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

        echo -e \"${GREEN}Installing Terraform...${NC}\"
        sudo dnf config-manager addrepo --from-repofile=https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
        sudo dnf -y install terraform

        source ~/.bashrc
        echo -e \"${GREEN}WSL setup process completed.${NC}\"
    "

    echo -e "${GREEN}WSL tools installation completed.${NC}"
}
