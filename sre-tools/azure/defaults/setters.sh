

function azure.set.subscription() {
    if [ -z "$1" ]; then
        echo -e "${RED}Please provide a subscription name as an argument.${NC}"
        return 1
    fi
    az account set --subscription "${1}"
}

function __myhelp_azure_setters__() {
    echo -e "     ${YELLOW}azure.set.subscription <subscription-name>${NC}  - Set the active Azure subscription by name"
}