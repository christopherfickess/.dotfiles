#!/bin/bash


function windows_first_time_setup() {
    echo -e "${GREEN}Starting Windows first-time setup...${NC}"
    
    _install_software_windows
    
    echo -e "${GREEN}Windows first-time setup completed.${NC}"
}


# ------------------
# Secret Functions
# ------------------
function _choco_install_tools() {
    
    echo -e "${GREEN}Installing Chocolatey...${NC}"
    # curl.exe -O https://cdn.teleport.dev/teleport-v18.4.0-windows-amd64-bin.zip


    # echo -e "${GREEN}Installing software via Chocolatey...${NC}"
    # choco install -y \
    #     7zip \
    #     awscli \
    #     docker-desktop \
    #     git \
    #     golang \
    #     helm \
    #     jq \
    #     k9s \
    #     kubernetes-cli \
    #     kubernetes-helm \
    #     nano \
    #     python \
    #     terraform \
    #     yq 
    #     zsh \
        # terracreds \

}

function _install_software_windows() {
    echo -e "${GREEN}Setting up Windows Software...${NC}"

    echo -ne "${YELLOW}Are you in an Admin Terminal...?${NC}"
    read -p ": (y/n): " admin_confirm
    if [[ ! "$admin_confirm" =~ ^[Yy]$ ]]; then
        echo -e "${RED}Please restart the terminal as Administrator and rerun this script.${NC}"
        return 1
    fi

    _choco_install
    
    go install github.com/hidetatz/kubecolor/cmd/kubecolor@latest
}

