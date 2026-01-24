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
    if [[ ! "$admin_confirm" =~ ^[Yy]$ ]]; then
        echo -e "${RED}Please restart the terminal as Administrator and rerun this script.${NC}"
        return 1
    fi

    __choco_install_tools__
}

function __choco_install_tools__() {
    
    echo -e "${GREEN}Installing Apps...${NC}"
    # curl.exe -O https://cdn.teleport.dev/teleport-v18.4.0-windows-amd64-bin.zip

    # Upgrade first
    winget upgrade --all --accept-source-agreements --accept-package-agreements

    # Install all these
    winget install --id Git.Git --accept-source-agreements --accept-package-agreements -e
    winget install --id HashiCorp.Terraform --accept-source-agreements --accept-package-agreements -e
    winget install --id Python.Python.3.13.5 --accept-source-agreements --accept-package-agreements -e
    winget install --id Amazon.AWSCLI --accept-source-agreements --accept-package-agreements -e
    winget install --id Kubernetes.Kubectl --accept-source-agreements --accept-package-agreements -e
    winget install --id Helm.Helm --accept-source-agreements --accept-package-agreements -e
    winget install --id GoLang.Go --accept-source-agreements --accept-package-agreements -e
    winget install --id MikeFarah.yq --accept-source-agreements --accept-package-agreements -e
    winget install --id k9s.k9s --accept-source-agreements --accept-package-agreements -e
    winget install --id GNU.Nano --accept-source-agreements --accept-package-agreements -e
    winget install --id Stedolan.jq --accept-source-agreements --accept-package-agreements -e
    winget install --id Kubecolor.kubecolor --accept-source-agreements --accept-package-agreements -e
    winget install --id Derailed.k9s --accept-source-agreements --accept-package-agreements -e

    # Finally, do one last upgrade
    winget upgrade --all --accept-source-agreements --accept-package-agreements
}