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

function set_wsl_setup_process(){
    WIN_DOTFILES_DIR="$HOME/.dotfiles"

    # Target Fedora distro
    FEDORA_DISTRO="FedoraLinux-43"    
    
    if wsl.exe -l -v | iconv -f UTF-16LE -t UTF-8 | sed 1,1d | awk '{print $2}' | grep -Fx "$FEDORA_DISTRO"; then
        echo "$FEDORA_DISTRO already installed."
    else
        echo "$FEDORA_DISTRO not found. Installing..."
        wsl.exe --install -d "$FEDORA_DISTRO"
        
        wsl --set-default $FEDORA_DISTRO

        DEFAULT_DISTRO=$(wsl -l -v | grep "Default" | awk '{print $1}' | tr -d '\r')

        
    fi
    echo -e "${GREEN}Setting up WSL environment...${NC}"        
    _setup_wsl_environment
}

function _setup_wsl_environment() {
    wsl sh -c "
        USERNAME='ChrisFickess'
        cat /mnt/c/Users/$USERNAME/.bashrc >> ~/.bashrc
        ln -sf /mnt/c/Users/${USERNAME}/.dotfiles ~/
        ln -sf /mnt/c/Users/${USERNAME}/git ~/
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
            build-essential \
            containers-common \
            dos2unix \
            yq
            
        go install github.com/hidetatz/kubecolor/cmd/kubecolor@latest
        export PATH=$PATH:$HOME/go/bin

        find ~/.dotfiles -type f -exec dos2unix {} +

        source ~/.bashrc
        echo -e '${GREEN}WSL setup process completed.${NC}'
        "
}

function _remove_line_endings() {
    # Useful if there are windows line ending issues
    wsl sh -c "
        dos2unix ~/.dotfiles/.bashrc \
            ~/.dotfiles/.bash_aliases \
            ~/.dotfiles/.bash_functions \
            ~/.dotfiles/aws/kubernetes_functions.sh \
            ~/.dotfiles/aws/aws_functions.sh \
            ~/.dotfiles/windows/.bashrc \
            ~/.dotfiles/windows/.bashrc \
            ~/.dotfiles/windows/.bash_functions
    "
}

function destroy_wsl_distro(){
    
    if [ ! -z "$1" ]; then
        echo -e "${GREEN}Enter the name of the distribution to unregister${NC}"
        read -p "(delete): " DISTRO_NAME        
    else
        DISTRO_NAME="FedoraLinux-43" 
    fi

    echo "Unregistering (deleting) WSL distribution: $DISTRO_NAME"
    wsl -t "$DISTRO_NAME"
    wsl --unregister "$DISTRO_NAME"

    echo "Distribution $DISTRO_NAME has been unregistered."
}