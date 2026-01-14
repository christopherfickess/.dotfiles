#!/bin/bash

# Install necessary tools for Mac environment

function mac_install(){
    echo -e "${GREEN}Installing Base tool chain for Mac${NC}"

    _install_mac_software
}

function _install_mac_software() {
    echo -e "${GREEN}Installing necessary tools for Mac...${NC}"

    brew update

    if ! command -v brew &> /dev/null; then
        echo -e "${RED}Homebrew is not installed. Please install Homebrew first.${NC}"
        return 1
    # elif ! brew doctor &> /dev/null; then
    #     echo -e "${RED}Homebrew is not in a healthy state. Please run 'brew doctor' to fix any issues.${NC}"
    #     return 1
    fi

    echo -e "${GREEN}Installing AWS CLI...${NC}"
    brew update

    brew install awscli 
    brew install curl 
    brew install docker 
    brew install dos2unix 
    brew install dstat 
    brew install fzf 
    brew install gcc 
    brew install git 
    brew install go 
    brew install helm 
    brew install htop 
    brew install jq 
    brew install k9s 
    brew install kubectl 
    brew install nano 
    brew install nmap 
    brew install openssl 
    brew install pipx 
    brew install sysstat 
    brew install tree 
    brew install unzip 
    brew install vim 
    brew install wget 
    brew install yamllint 
    brew install yq 
    brew install zsh


    # Optional but useful
    brew install --cask docker

    echo -e "${GREEN}Installing kubecolor...${NC}"
    go install github.com/hidetatz/kubecolor/cmd/kubecolor@latest

    echo -e "${GREEN}Installing Teleport...${NC}"

    mkdir -p ~/bin
    pushd ~/bin
    curl -LO https://cdn.teleport.dev/teleport-${TELEPORT_VERSION}-darwin-amd64-bin.tar.gz
    tar -xzf teleport-${TELEPORT_VERSION}-darwin-amd64-bin.tar.gz
    sudo ./teleport/install
    popd

    echo -e "${GREEN}Installing Minikube...${NC}"
    brew install minikube

    echo -e "${GREEN}Installing Terraform...${NC}"
    brew tap hashicorp/tap
    brew install hashicorp/tap/terraform
}
