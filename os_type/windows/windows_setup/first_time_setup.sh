#!/bin/bash


function setup_windows() {
    echo -e "${GREEN}Starting Windows first-time setup...${NC}"
    
    __install_software_windows__
    
    echo -e "${GREEN}Windows first-time setup completed.${NC}"
}

# ------------------
# Secret Functions
# ------------------
function __install_software_windows__() {
    echo -e "${GREEN}Setting up Windows Software...${NC}"

    echo -ne "${YELLOW}Are you in an Admin Terminal...?${NC}"
    read -p ": (y/n): " admin_confirm

    if [[ "$admin_confirm" =~ ^[Yy]$ ]]; then
        echo -e "${RED}Since User is not admin, Installing local tools as Non Admin.${NC}"
        echo -e "${YELLOW}   To Continue with User Installation, Press Enter...${NC}"
        read -r
        __winget_install_tools__
    elif [[  ! "$admin_confirm" =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}User confirmed Admin Terminal. Proceeding with Admin Installation...${NC}"
        echo -e "${YELLOW}   To Continue with Admin Installation, Press Enter...${NC}"
        read -r
        __choco_install_tools__
    fi
}

function __winget_install_tools__() {
    
    echo -e "${MAGENTA}   Do you wish to install Azure Tools (Azure CLI, Azure PowerShell, Azure Storage Explorer)?${NC}"
    read -p "   (y/n): " __install_azure_tools__

    echo -e "${GREEN}Installing Apps...${NC}"
    # curl.exe -O https://cdn.teleport.dev/teleport-v18.4.0-windows-amd64-bin.zip

    # Upgrade first
    winget upgrade --all --accept-source-agreements --accept-package-agreements

    packages=(
        "Microsoft.VisualStudioCode:Visual Studio Code"
        "Hashicorp.Terraform:Terraform"
        "Python.Python.3.13.5:Python 3.13.5"
        "OpenJS.NodeJS.LTS:Node.js LTS"
        "Amazon.AWSCLI:AWS CLI"
        "Kubernetes.Kubectl:Kubectl"
        "Helm.Helm:Helm"
        "GoLang.Go:Go"
        "MikeFarah.yq:yq"
        "Derailed.k9s"
        "GNU.Nano:GNU Nano"
        "jqlang.jq:jq"
        "Kubecolor.kubecolor:Kubecolor"
        "StrawberryPerl.StrawberryPerl:Strawberry Perl"
        "MiKTeX.MiKTeX:MiKTeX"
    )

    # how to do case sensitive comparison in bash
    if [[ "${__install_azure_tools__}" =~ ^[Yy]$ ]]; then
        packages+=("Microsoft.AzureCLI:Azure CLI"
                    "Microsoft.Azure.PowerShell:Azure PowerShell"
                    "Microsoft.Azure.StorageExplorer:Azure Storage Explorer")
    fi

    echo -e "${GREEN}Installing required packages via winget...${NC}"

    for entry in "${packages[@]}"; do
        IFS=":" read -r id name <<< "$entry"

        if [[ "${entry}" == "MiKTeX.MiKTeX:MiKTeX" ]]; then
            read -p "   Do you want to install MiKTeX (LaTeX distribution)? (y/n): " install_miktex
            if [[ ! "$install_miktex" =~ ^[Yy]$ ]]; then
                echo -e "${YELLOW}   Skipping MiKTeX installation as per user choice.${NC}"
                continue
            fi
            if [[ "${entry}" == "StrawberryPerl.StrawberryPerl:Strawberry Perl" ]]; then
                read -p "   Do you want to install Strawberry Perl? (y/n): " install_perl
                if [[ ! "$install_perl" =~ ^[Yy]$ ]]; then
                    echo -e "${YELLOW}   Skipping Strawberry Perl installation as per user choice.${NC}"
                    continue
                fi
            fi
            continue
        fi

        echo -e "   Installing ${MAGENTA}${name}...${NC}"
        winget install -e --id "$id" \
            --accept-source-agreements \
            --accept-package-agreements
        echo ""
    done

    # Finally, do one last upgrade
    winget upgrade --all --accept-source-agreements --accept-package-agreements
}

# --------------------------------------------
# Custom Azure Tools Installation for winget
# --------------------------------------------
function __winget_install_azure_tools__() {
    echo -e "${MAGENTA}   Do you wish to install Azure Tools (Azure CLI, Azure PowerShell, Azure Storage Explorer)?${NC}"
    read -p "   (y/n): " __install_azure_tools__
    

    if [[ "$__install_azure_tools__" =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}   Installing / Updating Azure Tools...${NC}"

        winget install -e --id Microsoft.AzureCLI \
            --accept-source-agreements \
            --accept-package-agreements

        winget install -e --id Microsoft.Azure.PowerShell \
            --accept-source-agreements \
            --accept-package-agreements

        winget install -e --id Microsoft.Azure.StorageExplorer \
            --accept-source-agreements \
            --accept-package-agreements
    else
        echo -e "${YELLOW}   Skipping Azure Tools installation as per user choice.${NC}"
    fi
}


function __choco_install_tools__() {
    
    echo -e "${MAGENTA}   Do you wish to install Azure Tools (Azure CLI, Azure PowerShell, Azure Storage Explorer)?${NC}"
    read -p "   (y/n): " __install_azure_tools__

    echo -e "${GREEN}Installing Apps via Chocolatey...${NC}"


    declare -A CHOCO_CMDS=(
        [git]="git"
        [7zip]="7z"
        [googlechrome]="chrome"
        [notepadplusplus]="notepad++"
        [zoom]="zoom"
        # [sysinternals]="sysinternals"
        # [vlc]="vlc"
        # [windirstat]="windirstat"
        [terraform]="terraform"
        [python]="python"
        [nodejs-lts]="node"
        [awscli]="aws"
        [kubectl]="kubectl"
        [kubernetes-helm]="helm"
        [golang]="go"
        [yq]="yq"
        [k9s]="k9s"
        [nano]="nano"
        [jq]="jq"
        [strawberryperl]="perl"
        [miktex.install]="pdflatex"
        [openssh]="ssh"
    )

    if [[ "${__install_azure_tools__}" =~ ^[Yy]$ ]]; then
        CHOCO_CMDS+=(
            [azure-cli]="az"
            [azure-powershell]="Azure"
            [azure-storage-explorer]="StorageExplorer"
        )
    fi
    
    echo -e "${GREEN}Installing required packages via Chocolatey...${NC}"

    # Note: If there is a 404 error, 
    #       verify the chocolatey sources is correct.
    # choco source list
    #       If needed, reset the chocolatey source:
    # choco source remove -n chocolatey
    # choco source add -n chocolatey -s https://community.chocolatey.org/api/v2/
    for package in "${!CHOCO_CMDS[@]}"; do
        cmd="${CHOCO_CMDS[$package]}"
        if [[ "$package" == "miktex.install" ]]; then
            read -p "   Do you want to install MiKTeX (LaTeX distribution)? (y/n): " install_miktex
            if [[ ! "$install_miktex" =~ ^[Yy]$ ]]; then
                echo -e "${YELLOW}   Skipping MiKTeX installation as per user choice.${NC}"
                continue
            fi
        fi
        if [[ "$package" == "strawberryperl" ]]; then
            read -p "   Do you want to install Strawberry Perl? (y/n): " install_perl
            if [[ ! "$install_perl" =~ ^[Yy]$ ]]; then
                echo -e "${YELLOW}   Skipping Strawberry Perl installation as per user choice.${NC}"
                continue
            fi
        fi
        if __command_exists__ "$cmd"; then
            echo -e "   Skipping ${MAGENTA}$package${NC}, command ${MAGENTA}'$cmd'${NC} already exists"
            continue
        fi

        echo -e "   Installing ${MAGENTA}$package${NC}"
        choco upgrade "$package" -y
    done

    if command -v kubecolor >/dev/null 2>&1; then
        echo -e "   ${MAGENTA}kubecolor${NC} already installed. Skipping..."
    else
        echo -e "   Installing ${MAGENTA}kubecolor${NC}..."
        go install github.com/hidetatz/kubecolor/cmd/kubecolor@latest
    fi
    echo 
    echo -e "${GREEN}Checking for Azure Tools installation...${NC}"
    echo 
    echo
    __choco_install_azure_tools__

    echo -e "${GREEN}Chocolatey package installation completed.${NC}"
}

function __choco_install_azure_tools__() {
    echo -e "${MAGENTA}Do you wish to install Azure Tools (Azure CLI, Azure PowerShell, Azure Storage Explorer)?${NC}"
    read -p "   (y/n): " __install_azure_tools__
    if [[ "$__install_azure_tools__" =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}   Installing Azure Tools...${NC}"
        choco upgrade azure-cli -y
        choco upgrade azure-powershell -y
        choco upgrade azure-storage-explorer -y
    else
        echo -e "${YELLOW}   Skipping Azure Tools installation as per user choice.${NC}"
    fi
}

function __command_exists__() {
    command -v "$1" >/dev/null 2>&1
}