#!/bin/bash


if [ -f "$HOME/.dotfiles/windows/.bash_functions" ]; then  source "$HOME/.dotfiles/windows/.bash_functions"; fi

export PATH=$PATH:/c/Windows/System32

function windows_first_time_setup() {
    echo -e "${GREEN}Starting Windows first-time setup...${NC}"
    
    _install_software_windows
    
    set_wsl_setup_process
    echo -e "${GREEN}Windows first-time setup completed.${NC}"
}

function _install_software_windows() {
    echo -e "${GREEN}Setting up Windows Software...${NC}"

    echo -ne "${YELLOW}Are you in an Admin Terminal...?${NC}"
    read -p ": (y/n): " admin_confirm
    if [[ ! "$admin_confirm" =~ ^[Yy]$ ]]; then
        echo -e "${RED}Please restart the terminal as Administrator and rerun this script.${NC}"
        return 1
    fi

    
    # curl.exe -O https://cdn.teleport.dev/teleport-v18.4.0-windows-amd64-bin.zip


    # echo -e "${GREEN}Installing software via Chocolatey...${NC}"
    # choco install -y \
    #     git \
    #     kubernetes-cli \
    #     helm \
    #     awscli \
    #     jq \
    #     golang \
    #     docker-desktop \
    #     python \
    #     nano \
    #     terraform \
    #     7zip \
    #     kubernetes-helm \
    #     zsh \
    #     yq 
        # terracreds \

    go install github.com/hidetatz/kubecolor/cmd/kubecolor@latest
}
