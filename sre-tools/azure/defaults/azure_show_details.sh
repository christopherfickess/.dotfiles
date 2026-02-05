function __show_subscription_details__(){
    az account show --output json 
}

function __show_subscription_id__(){
    az account show --query "id" --output tsv
}

function __show_sp_id_from_name__(){
    if [ -z "${1}" ];then 
        echo -e "${RED}Pass in \$1 for service principal name${NC}"
        __service_principal_name__="terraform-sp-chris"
    else
        __service_principal_name__="${1}"
    fi
    __appID__=$(az ad sp list --display-name "${__service_principal_name__}" --query "[0].appId" -o tsv)
    echo -e "${MAGENTA}Service Principal App ID:${NC} ${__appID__}"
}

function __show_sp_role_assignments__(){
    if [ -z "${1}" ];then 
        echo -e "${RED}Pass in \$1 for service principal name${NC}"
        __service_principal_name__="terraform-sp-chris"
    else
        __service_principal_name__="${1}"
    fi
    __show_sp_id_from_name__ "${__service_principal_name__}"
    az role assignment list --assignee "${__appID__}" --output table
}

function __show_sp_credentials__(){
    if [ -z "${1}" ];then 
        echo -e "${RED}Pass in \$1 for service principal name${NC}"
        __service_principal_name__="terraform-sp-chris"
    else
        __service_principal_name__="${1}"
    fi
    az ad sp credential list --id "http://$__service_principal_name__" --output json
}

function __assign_role_sp__(){
    __subscription_id__=$(__show_subscription_id__)
    __rg_name__="chrisfickess-tfstate-azk"
    __storage_account__="tfstatechrisfickess"
    __container_name__="azure-azk-tfstate"
    __show_sp_id_from_name__ "terraform-sp-chris"
    echo -e "${MAGENTA}Resource Group:${NC} $__rg_name__"
    echo -e "${MAGENTA}Storage Account:${NC} $__storage_account__"
    echo -e "${MAGENTA}Container Name:${NC} $__container_name__"
    echo -e "${MAGENTA}Service Principal App ID:${NC} $__appID__"
    echo -e "${MAGENTA}Subscription ID:${NC} $__subscription_id__"
    
    az role assignment create \
        --assignee "$__appID__" \
        --role "Storage Blob Data Contributor" \
        --scope "/subscriptions/$__subscription_id__/resourceGroups/$__rg_name__/providers/Microsoft.Storage/storageAccounts/$__storage_account__"


    az role assignment create \
        --assignee "$__appID__" \
        --role "Contributor" \
        --scope "/subscriptions/$__subscription_id__/resourceGroups/$__rg_name__"

    # Assign User Access Administrator on the resource group
    az role assignment create \
        --assignee "$__appID__" \
        --role "User Access Administrator" \
        --scope "/subscriptions/$__subscription_id__/resourceGroups/$__rg_name__"
        
    az role assignment list \
        --assignee "$__appID__" \
        --output table
}