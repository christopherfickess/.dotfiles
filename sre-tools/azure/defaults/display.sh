function azure.display.subscription.details(){
    az account show --output json 
}

function azure.display.subscription.id(){
    az account show --query "id" --output tsv
}

function azure.display.sp.id.from.name(){
    if [ -z "${1}" ];then 
        echo -e "${RED}Pass in \$1 for service principal name${NC}"
        __service_principal_name__="terraform-sp-chris"
    else
        __service_principal_name__="${1}"
    fi
    __appID__=$(az ad sp list --display-name "${__service_principal_name__}" --query "[0].appId" -o tsv)
    echo -e "${MAGENTA}Service Principal App ID:${NC} ${__appID__}"
}

function azure.display.sp.role.assignments(){
    if [ -z "${1}" ];then 
        echo -e "${RED}Pass in \$1 for service principal name${NC}"
        __service_principal_name__="terraform-sp-chris"
    else
        __service_principal_name__="${1}"
    fi
    azure.display.sp.id.from.name "${__service_principal_name__}"
    az role assignment list --assignee "${__appID__}" --output table
}

function azure.display.sp.credentials(){
    if [ -z "${1}" ];then 
        echo -e "${RED}Pass in \$1 for service principal name${NC}"
        __service_principal_name__="terraform-sp-chris"
    else
        __service_principal_name__="${1}"
    fi
    az ad sp credential list --id "http://$__service_principal_name__" --output json
}

function azure.assign.role.sp(){
    __subscription_id__=$(azure.display.subscription.id)
    __rg_name__="chrisfickess-tfstate-azk"
    __storage_account__="tfstatechrisfickess"
    __container_name__="azure-azk-tfstate"
    azure.display.sp.id.from.name "terraform-sp-chris"
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

function __myhelp_azure_display__(){
    echo -e "     ${YELLOW}azure.display.subscription.details${NC}           - Show details of the current Azure subscription"
    echo -e "     ${YELLOW}azure.display.subscription.id${NC}                - Show the current Azure subscription ID"
    echo -e "     ${YELLOW}azure.display.sp.id.from.name <sp-name>${NC}      - Get the App ID of a service principal by name"
    echo -e "     ${YELLOW}azure.display.sp.role.assignments <sp-name>${NC}  - Show role assignments for a service principal"
    echo -e "     ${YELLOW}azure.display.sp.credentials <sp-name>${NC}       - Show credentials for a service principal"
    echo -e "     ${YELLOW}azure.assign.role.sp${NC}                      - Assign Storage Blob Data Contributor and Contributor roles to the SP on the storage account and resource group"
}