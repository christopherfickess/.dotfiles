# These will be getter functions
function azure.get.aks_credentials() {
    export __aks_cluster_name__="${1:-$__aks_cluster_name__}"
    export __aks_resource_group__="${2:-$__aks_resource_group__}"
    
    az aks get-credentials --resource-group $__aks_resource_group__ --name $__aks_cluster_name__ --overwrite-existing
}

function azure.get.aks_roles(){
    export __aks_cluster_name__="${1:-$__aks_cluster_name__}"
    export __aks_resource_group__="${2:-$__aks_resource_group__}"
    
    export aks_resource_id=$(az aks show --name  ${__aks_cluster_name__} --resource-group "${__aks_resource_group__}" --query "id" -o tsv)
    
    
    az role assignment list --scope $aks_resource_id
}

function azure.get.details() {
    export __azure_PDE__="Azure PDE"
    export __get_group_object_id__=$(az ad group show --group $__azure_PDE__ --query id -o tsv)
}

function azure.get.member_groups() {
    local __user_principal_name__="${1:-$__email__}"
    if [ -z "$__user_principal_name__" ]; then
        echo -e "${RED}Please provide a user principal name as an argument.${NC}"
        return 1
    fi

    echo -e "${GREEN}Fetching group assignments for user: ${MAGENTA}$__user_principal_name__${NC}${GREEN}...${NC}"
    
    az ad user get-member-groups \
        --id "$__user_principal_name__" \
        --security-enabled-only
}

function azure.get.role_assignments() {
    export __email__="${1:-$__email__}"

    az role assignment list --assignee "$__email__"
}

function azure.get.subscription_id() {
    export AZURE_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
    export ARM_SUBSCRIPTION_ID="$AZURE_SUBSCRIPTION_ID"
    echo -e "${MAGENTA}Azure Subscription ID:${NC} $AZURE_SUBSCRIPTION_ID"
}

function azure.get.tenant_id() {
    export AZURE_TENANT_ID=$(az account show --query tenantId -o tsv)
    export ARM_TENANT_ID="$AZURE_TENANT_ID"
    echo -e "${MAGENTA}Azure Tenant ID:${NC} $AZURE_TENANT_ID"  
}

function __myhelp_azure_getters__() {
    echo -e "     ${YELLOW}azure.get.aks_credentials <cluster_name> <rg>${NC}   - Get AKS cluster credentials and update kubeconfig"
    echo -e "     ${YELLOW}azure.get.aks_roles <cluster_name> <rg>${NC}         - Get role assignments for an AKS cluster"
    echo -e "     ${YELLOW}azure.get.details${NC}                               - Get details about the Azure environment"
    echo -e "     ${YELLOW}azure.get.member_groups <user_email>${NC}            - Get Azure AD group assignments for a user"
    echo -e "     ${YELLOW}azure.get.role_assignments <user_email>${NC}         - Get role assignments for a user"
    echo -e "     ${YELLOW}azure.get.subscription_id${NC}                       - Get the current Azure subscription ID"
    echo -e "     ${YELLOW}azure.get.tenant_id${NC}                             - Get the current Azure tenant ID"
}