#!/bin/bash

function _list_windows_wsl_commands(){
    echo -e "wsl -l                                     ${GREEN}# List installed Linux distributions${NC}"
    echo -e "wsl -l -v                                  ${GREEN}# List installed distros with version/state${NC}"
    echo -e "wsl -l -o                                  ${GREEN}# List available distros (online)${NC}"
    echo -e ""
    echo -e "wsl --install                              ${GREEN}# Install WSL with default distro${NC}"
    echo -e "wsl --install <distro>                     ${GREEN}# Install a specific distro${NC}"
    echo -e "wsl --unregister <distro>                  ${GREEN}# Unregister (delete) a distro${NC}"
    echo -e ""
    echo -e "wsl --export <distro> <file.tar>           ${GREEN}# Export distro filesystem${NC}"
    echo -e "wsl --import <name> <folder> <file.tar>    ${GREEN}# Import from TAR${NC}"
    echo -e "wsl --set-default <distro>                 ${GREEN}# Set default distro${NC}"
    echo -e "wsl --set-default-version <1|2>            ${GREEN}# Set default WSL version${NC}"
    echo -e "wsl --set-version <distro> <1|2>           ${GREEN}# Change WSL version for a distro${NC}"
    echo -e ""
    echo -e "wsl --status                ${GREEN}# Show WSL status + default distro${NC}"
    echo -e "wsl --shutdown              ${GREEN}# Shut down all WSL instances${NC}"
    echo -e "wsl --terminate <distro>    ${GREEN}# Stop a specific distro${NC}"
    echo -e ""
    echo -e "wsl <command>               ${GREEN}# Run command in default distro${NC}"
    echo -e "wsl -d <distro> <command>   ${GREEN}# Run command in specific distro${NC}"
    echo -e "wsl -u <user> <command>     ${GREEN}# Run as specific user${NC}"
    echo -e "wsl --exec <command>        ${GREEN}# Execute command without a shell${NC}"
    echo -e ""
    echo -e "wsl hostname                ${GREEN}# Get hostname inside WSL${NC}"
    echo -e "wsl ip addr                 ${GREEN}# Get IP/network info${NC}"
    echo -e "wsl cat /proc/version       ${GREEN}# Show kernel version${NC}"
    echo -e ""
    echo -e "wslpath <WinPath>           ${GREEN}# Convert Windows path to Linux path${NC}"
    echo -e "wslpath -w <LinuxPath>      ${GREEN}# Convert Linux path to Windows path${NC}"
    echo -e ""
    echo -e "wsl --update                ${GREEN}# Update WSL kernel and components${NC}"
    echo -e "wsl --update rollback       ${GREEN}# Roll back last WSL kernel update${NC}"
}

function wsl() {
    echo -e "${GREEN}Running pre-WSL checks...${NC}"
    echo

    # Example check: verify that a WSL distro exists
    if ! command -v wsl.exe > /dev/null; then
        echo -e "   ${RED}WSL not found on this system.${NC}"
        return 1
    fi

    set_wsl_setup_process
    
    echo
    echo -e "Launching WSL..."
    wsl.exe "$@"
}

function set_wsl_setup_process(){
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

function _setup_wsl_environment() {
    
    _install_wsl_tools

    if [ "$MATTERMOST" = "TRUE" ]; then _setup_mattermost_mmutils;  fi
}

function _install_wsl_tools() {
    echo -e "${GREEN}Installing WSL tools...${NC}"
    
    wsl.exe sh -c '
        cat /mnt/c/Users/${USER}/.bashrc >> ~/.bashrc
        ln -sf /mnt/c/Users/${USER}/.dotfiles ~/
        ln -sf /mnt/c/Users/${USER}/git ~/

        
        echo -e "${GREEN}Installing Teleport...${NC}"
        
        mkdir -p $HOME/bin
        pushd $HOME/bin;
            curl -O https://cdn.teleport.dev/teleport-v18.4.0-linux-amd64-bin.tar.gz
            tar -xzf teleport-v18.4.0-linux-amd64-bin.tar.gz
            cd teleport
            sudo ./install
        popd

        sudo dnf update -y
        sudo dnf install -y --skip-unavailable \
            git \
            vim \
            wget \
            curl \
            kubectl \
            helm \
            awscli \
            jq \
            golang-go \
            docker \
            pip \
            nano \
            unzip \
            containers-common \
            dos2unix \
            zsh \
            yq
            
        go install github.com/hidetatz/kubecolor/cmd/kubecolor@latest

        find ~/.dotfiles -type f -exec dos2unix {} +

        source ~/.bashrc
        echo -e '${GREEN}WSL setup process completed.${NC}'
    '

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