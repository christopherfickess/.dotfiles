#!/bin/bash

# Install necessary tools for Linux environment
function _install_linux_software() {
    echo -e "${GREEN}Installing necessary tools for Linux...${NC}"

    if command -v apt-get &> /dev/null; then
        sudo apt-get update

        sudo apt-get install -y \
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

        echo -e "${GREEN}Linux tools installation completed.${NC}"
    elif command -v dnf &> /dev/null; then
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
            yq \
            zsh

        go install github.com/hidetatz/kubecolor/cmd/kubecolor@latest

        echo -e "${GREEN}Linux tools installation completed.${NC}"
    elif command -v yum &> /dev/null; then
        sudo yum update -y

        sudo yum install -y \
            awscli \
            curl \
            docker \
            dos2unix \
            fzf \
            git \
            golang \
            helm \
            htop \
            jq \
            kubectl \
            nano \
            nmap \
            openssl \
            pip3 \
            unzip \
            vim \
            wget \
            yq

        go install github.com/hidetatz/kubecolor/cmd/kubecolor@latest

        echo -e "${GREEN}Linux tools installation completed.${NC}"
    else
        echo -e "${RED}Unsupported package manager. Please install the required tools manually.${NC}"
    fi
}


if ! aws --version &> /dev/null; then
    echo -e "       ${MAGENTA}Linux Tools not installed. Proceeding with installation...${NC}"
    _install_linux_software
fi