

function azure.set.subscription() {
    if [ -z "$1" ]; then
        echo -e "${RED}Please provide a subscription name as an argument.${NC}"
        return 1
    fi
    az account set --subscription "${1}"
}
