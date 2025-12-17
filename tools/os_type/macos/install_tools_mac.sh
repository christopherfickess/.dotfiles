#!/bin/bash

# Install necessary tools for Mac environment
function _install_mac_software() {
    echo -e "${GREEN}Installing necessary tools for Mac...${NC}"

    brew update

    if ! command -v brew &> /dev/null; then
        echo -e "${RED}Homebrew is not installed. Please install Homebrew first.${NC}"
        return 1
    elif ! brew doctor &> /dev/null; then
        echo -e "${RED}Homebrew is not in a healthy state. Please run 'brew doctor' to fix any issues.${NC}"
        return 1
    elif ! command -v aws &> /dev/null; then
        echo -e "${GREEN}Installing AWS CLI...${NC}"
        brew install \
            awscli \
            bash \
            bash-completion \
            curl \
            docker \
            git \
            golang \
            helm \
            jq \
            kubectl \
            minikube \
            nano \
            pip3 \
            unzip \
            vim \
            wget \
            yamllint \
            yq

        go install github.com/hidetatz/kubecolor/cmd/kubecolor@latest

        teleport_version=$(brew list --versions teleport | awk '{print $2}')
        if [ -z "$teleport_version" ]; then
            echo -e "${GREEN}Installing Teleport...${NC}"
            brew install teleport
        else
            echo -e "${GREEN}Teleport is already installed (version: $teleport_version). Skipping installation.${NC}"
        fi

        echo -e "${GREEN}Mac tools installation completed.${NC}"
    fi
}

if ! aws --version &> /dev/null; then
    echo -e "       ${MAGENTA}AWS CLI not found. Proceeding with installation...${NC}"
    _install_mac_software
fi

