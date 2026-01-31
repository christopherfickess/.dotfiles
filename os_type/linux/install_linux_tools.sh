#!/bin/bash

set -e

function setup_linux() {
    echo -e "${GREEN}Setting up Linux environment...${NC}"
    __install_linux_software__
}

function __install_linux_software__() {
    echo -e "${GREEN}Installing necessary tools for Linux...${NC}"

    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update -y
        sudo apt-get upgrade -y

        sudo apt-get install -y \
            awscli \
            containers-common \
            curl \
            docker.io \
            dos2unix \
            dstat \
            gettext-base \
            fzf \
            gcc \
            git \
            golang-go \
            htop \
            iftop \
            iotop \
            jq \
            nano \
            nmap \
            openssl \
            python3-pip \
            sysstat \
            tree \
            unzip \
            vim \
            wget \
            yamllint \
            yq \
            zsh

    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf update -y

        sudo dnf install -y \
            awscli \
            azure-cli \
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
            htop \
            iftop \
            iotop \
            jq \
            nano \
            nmap \
            openssl \
            python3-pip \
            sysstat \
            tree \
            unzip \
            vim \
            wget \
            yamllint \
            yq \
            zsh

    elif command -v yum >/dev/null 2>&1; then
        sudo yum update -y

        sudo yum install -y \
            awscli \
            curl \
            docker \
            dos2unix \
            fzf \
            gcc \
            git \
            golang \
            htop \
            jq \
            nano \
            nmap \
            openssl \
            python3-pip \
            sysstat \
            tree \
            unzip \
            vim \
            wget \
            yq \
            zsh
    else
        echo -e "${RED}Unsupported package manager.${NC}"
        return 1
    fi

    echo -e "${GREEN}Base packages installed.${NC}"

    if command -v kubecolor >/dev/null 2>&1; then
        echo -e "${GREEN}kubecolor already installed.${NC}"
    else
        echo -e "${GREEN}Installing kubecolor...${NC}"
        go install github.com/hidetatz/kubecolor/cmd/kubecolor@latest
    fi
    
    if command -v terraform >/dev/null 2>&1; then
        echo -e "${GREEN}Terraform already installed.${NC}"
    else
        __install_terraform__
    fi

    if command -v kubectl >/dev/null 2>&1 && command -v minikube >/dev/null 2>&1; then
        echo -e "${GREEN}Kubernetes tools already installed.${NC}"
    else
        __install_kubernetes_tools__
    fi
    if command -v docker &>/dev/null; then
        __configure_docker__
    else
        if command -v apt-get >/dev/null 2>&1; then
            echo -e "${GREEN}Installing Docker...${NC}"
            sudo apt-get install -y docker.io
        elif command -v dnf >/dev/null 2>&1; then
            echo -e "${GREEN}Installing Docker...${NC}"
            sudo dnf install -y docker
        elif command -v yum >/dev/null 2>&1; then
            echo -e "${GREEN}Installing Docker...${NC}"
            sudo yum install -y docker
        else
            echo -e "${RED}Unsupported package manager. Cannot install Docker.${NC}"
        fi
        __configure_docker__
    fi
    
    if command -v flux &>/dev/null; then
        echo -e "${GREEN}Flux already installed.${NC}"
    else
        __install_flux__
    fi

    if command -v session-manager-plugin &>/dev/null; then
        echo -e "${GREEN}AWS Session Manager Plugin already installed.${NC}"
    else
        __install_session_manager_plugin__
    fi

    if command -v teleport &>/dev/null; then
        echo -e "${GREEN}Teleport already installed.${NC}"
    else
        __install_teleport__
    fi
}

function __check_architecture__() {
    
    export ARCH=$(uname -m)
    case "$ARCH" in
        x86_64) LINUX_ARCH="amd64" ;;
        aarch64) LINUX_ARCH="arm64" ;;
        *)
            echo "Unsupported architecture: $ARCH"
            return 1
            ;;
    esac
}

function __install_terraform__() {
    echo -e "${GREEN}Installing Terraform...${NC}"

    if [[ -z "$TERRAFORM_VERSION" ]]; then
        echo "TERRAFORM_VERSION is not set"
        return 1
    fi

    __check_architecture__

    TMP_DIR=$(mktemp -d)
    cd "$TMP_DIR"

    wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${LINUX_ARCH}.zip
    unzip terraform_${TERRAFORM_VERSION}_linux_${LINUX_ARCH}.zip
    sudo install terraform /usr/local/bin/terraform

    cd /
    rm -rf "$TMP_DIR"

    terraform version
}

function __install_kubernetes_tools__() {
    echo -e "${GREEN}Installing Kubernetes tools...${NC}"

    __check_architecture__

    TMP_DIR=$(mktemp -d)
    cd "$TMP_DIR"

    KUBECTL_VERSION=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)

    curl -LO "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/${LINUX_ARCH}/kubectl"
    chmod +x kubectl
    sudo install kubectl /usr/local/bin/kubectl

    curl -LO "https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-${LINUX_ARCH}"
    chmod +x minikube-linux-${LINUX_ARCH}
    sudo install minikube-linux-${LINUX_ARCH} /usr/local/bin/minikube

    cd /
    rm -rf "$TMP_DIR"

    kubectl version --client
    minikube version
}

function __configure_docker__() {
    echo -e "${GREEN}Install and Configuring Docker user...${NC}"

    if getent group docker >/dev/null; then
        sudo usermod -aG docker "$USER"
    fi

    echo -e "${GREEN}Docker setup complete. Log out and back in.${NC}"
}

function __install_flux__() {
    echo -e "${GREEN}Installing Flux...${NC}"
    curl -s https://fluxcd.io/install.sh | sudo bash
    flux --version
}
function __install_session_manager_plugin__() {
    echo -e "${GREEN}Installing AWS Session Manager Plugin...${NC}"

    TMP_DIR=$(mktemp -d)
    cd "$TMP_DIR"

    if command -v apt-get >/dev/null 2>&1; then
        curl -LO https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb
        sudo dpkg -i session-manager-plugin.deb

    elif command -v dnf >/dev/null 2>&1 || command -v yum >/dev/null 2>&1; then
        curl -LO https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm
        sudo rpm -i session-manager-plugin.rpm
    fi

    cd /
    rm -rf "$TMP_DIR"

    session-manager-plugin --version || true
}

function __install_teleport__() {
    echo -e "${GREEN}Setting up Teleport...${NC}"

    if [[ -z "$TELEPORT_VERSION" ]]; then
        echo "TELEPORT_VERSION is not set"
        return 1
    fi

    __check_architecture__

    TMP_DIR=$(mktemp -d)
    cd "$TMP_DIR"

    curl -LO https://cdn.teleport.dev/teleport-${TELEPORT_VERSION}-linux-${LINUX_ARCH}-bin.tar.gz
    tar -xzf teleport-${TELEPORT_VERSION}-linux-${LINUX_ARCH}-bin.tar.gz
    cd teleport
    sudo ./install

    cd /
    rm -rf "$TMP_DIR"

    teleport version
}
