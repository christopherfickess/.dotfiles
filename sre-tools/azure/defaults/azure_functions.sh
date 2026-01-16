
function azure_profile_switch(){
    if [ -z "${1}" ];then 
        while true; do
            __azure_profile_list__
            
            echo -e "${YELLOW}Enter Azure Profile to switch to: ${NC}"
            read -p "   :>  " __selected_profile__

            if az account show --query "name" --output tsv | grep -q "^${__selected_profile__}$"; then
                az account set --subscription "${__selected_profile__}"
                echo -e "${GREEN}Switched to profile: ${__selected_profile__}${NC}"
                break
            else
                echo -e "${RED}Profile '${__selected_profile__}' not found. Please try again.${NC}"
            fi
        done
    else
        az account set --subscription "${1}"
        echo -e "${GREEN}Switched to profile: ${1}${NC}"
    fi
}

function __azure_profile_list__(){
    echo
    echo -e "${YELLOW}Available Azure Profiles:${NC}"
    az account list --query "[].name" --output tsv | nl -w2 -s'. '
    echo
}

function azure_auth_update() {
    code ~/.azure/credentials
}

function __azure_show__(){
    az account show
}

function __azure_show_user__(){
    az account show --query "user"
}

function __azure_show_tenant__(){
    az account show --query "tenantId"
}

function __azure_show_subscription__(){
    az account list --output table
}

function __azure_set_subscription__(){
    if [ -z "${1}" ];then 
        echo -e "${RED}Pass in \$1 for subscription name or ID${NC}"
    else
        az account set --subscription "${1}"
    fi
}