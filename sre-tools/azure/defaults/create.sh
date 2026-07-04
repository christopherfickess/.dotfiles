
function azure.create.tf.sp() {
    azure.create.service.principal "$@"
    
    echo -e "${GREEN}Creating storage container '${__container_name__}' if it does not exist...${NC}"

    az storage container show --name "$__container_name__" --account-name "$__storage_account__" &>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "${YELLOW}Container '${__container_name__}' already exists. Skipping creation.${NC}"
    else
        echo -e "${GREEN}Container '${__container_name__}' does not exist. Creating...${NC}"
    
        az storage container create \
            --name "$__container_name__" \
            --account-name "$__storage_account__" \
            --only-show-errors \
            --output none
    fi

    # Get Subscription ID
    __subscription_id__=$(az account show --query id -o tsv)

    echo -e "${GREEN}Assigning 'Storage Blob Data Contributor' role to SP on the container...${NC}"

    az role assignment create \
        --assignee "$__app_id__" \
        --role "Storage Blob Data Contributor" \
        --scope "/subscriptions/$__subscription_id__/resourceGroups/$__rg_name__/providers/Microsoft.Storage/storageAccounts/$__storage_account__/blobServices/default/containers/$__container_name__" 

    echo -e "${GREEN}Service Principal created and configured for Terraform!${NC}"
    echo -e "Set these environment variables for Terraform:"
    echo "export ARM_CLIENT_ID=$__app_id__"
    echo "export ARM_CLIENT_SECRET=$__password__"
    echo "export ARM_TENANT_ID=$__tenant__"
    echo "export ARM_SUBSCRIPTION_ID=$__subscription_id__"
}


function azure.create.service.principal() {
    # Default values for parameters
    # __app_name__
    # __rg_name__
    # __storage_account__
    # __container_name__

    echo -e "\n${GREEN}Creating service principal '${__app_name__}'...${NC}"
    az ad sp get --id "http://$__app_name__" &>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "${YELLOW}Service principal '${__app_name__}' already exists. Do you wish to continue? (y/n)${NC}"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo -e "${RED}Aborting service principal creation.${NC}"
        else
            echo -e "${GREEN}Continuing with existing service principal.${NC}"
            __sp_json__=$(az ad sp create-for-rbac --name "$__app_name__" --skip-assignment -o json)
        fi
    fi
    __sp_json__=$(az ad sp create-for-rbac --name "$__app_name__" --skip-assignment -o json)
    __app_id__=$(echo "$__sp_json__" | jq -r .appId)
    __password__=$(echo "$__sp_json__" | jq -r .password)
    __tenant__=$(echo "$__sp_json__" | jq -r .tenant)

    echo -e "   ${MAGENTA}App ID:${NC} $__app_id__"
    echo -e "   ${MAGENTA}Password:${NC} $__password__"
    echo -e "   ${MAGENTA}Tenant ID:${NC} $__tenant__"
    echo -e "   ${MAGENTA}Resource Group:${NC} $__rg_name__"
    echo -e "   ${MAGENTA}Storage Account:${NC} $__storage_account__"
    echo -e "   ${MAGENTA}Container Name:${NC} $__container_name__"
    echo -e "   ${MAGENTA}Password:${NC} $__password__"
    echo
    echo -e "${MAGENTA}Service Principal Created (Save these credentials securely)...${NC}"
    read -p "Press Enter to continue with creating the storage container..."
}
