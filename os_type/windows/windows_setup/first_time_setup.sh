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

    __winget_install_tools__
}

function __winget_install_tools__() {
    
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
        # "MiKTeX.MiKTeX:MiKTeX"
        # "StrawberryPerl.StrawberryPerl:Strawberry Perl"

    )

    echo -e "${GREEN}Installing required packages via winget...${NC}"

    for entry in "${packages[@]}"; do
        IFS=":" read -r id name <<< "$entry"

        echo -e "   Installing ${MAGENTA}${name}...${NC}"
        winget install -e --id "$id" \
            --accept-source-agreements \
            --accept-package-agreements
        echo ""
    done


    # Finally, do one last upgrade
    winget upgrade --all --accept-source-agreements --accept-package-agreements
}