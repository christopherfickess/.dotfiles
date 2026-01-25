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

    echo -e "Installing Distro: ${MAGENTA}$__distro_type__${NC}"

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

    
    
    wsl.exe env \
        USERNAME="$USERNAME" \
        TERRAFORM_VERSION="$TERRAFORM_VERSION" \
        TELEPORT_VERSION="$TELEPORT_VERSION" \
        sh -lc "
        set -e
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

        source ~/.dotfiles/bash_dir/public_env.sh # ENV VARIABLES
        source ~/.dotfiles/bash_dir/.bash_aliases   # ALIASES
        source ~/.dotfiles/os_type/linux/install_linux_tools.sh
        setup_linux
    "

    echo -e "${GREEN}WSL tools installation completed.${NC}"
}
