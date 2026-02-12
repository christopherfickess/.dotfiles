

function azure.sandbox() {
    azure.sandbox.env;
    
    # Set the default subscription
    azure.set.subscription "$SUBSCRIPTION_NAME"

    # Optional: set environment variable for scripts that need subscription ID
    azure.get.subscription_id
    azure.get.tenant_id
   

    # Function at bottom of this file to display environment info
    azure.display.env
}

function azure.sandbox.connect(){
    __azure_cluster_name__="${__sandbox_cluster_name__}"
    __resource_group__="${__aks_resource_group__}"

    azure.sandbox
    echo 
    echo -e "Connecting to AKS cluster ${CYAN}$__azure_cluster_name__...${NC}"
    azure.get.aks_credentials $__azure_cluster_name__ $__resource_group__

    echo 
    echo -e "Converting kubeconfig to use Azure CLI for authentication...${NC}"
    kubelogin convert-kubeconfig -l azurecli
    echo -e "${GREEN}Connected to AKS cluster '$__azure_cluster_name__'!${NC}"
}

function azure.sandbox.terraform.accesskey() {
    echo -e "Setting Azure environment for ${CYAN}Sandbox Terraform Access Key...${NC}"
    export ACCOUNT_KEY=$(az storage account keys list \
        --resource-group $__aks_resource_group__ \
        --account-name tfstatechrisfickess \
        --query '[0].value' -o tsv)

    echo -e "   ${MAGENTA}Terraform Access Key:${NC} ${ACCOUNT_KEY}"
}

function azure.create.sandbox.service.principal() {
    export __app_name__="terraform-sp-chris"
    export __rg_name__="chrisfickess-tfstate-azk"
    export __storage_account__="tfstatechrisfickess"
    export __container_name__="azure-azk-tfstate"
    azure.create.tf.sp
}








function azure.display.env(){
    # Optional: print connection info
    echo -e "   ${MAGENTA}Subscription:${NC} $SUBSCRIPTION_NAME"
    echo -e "   ${MAGENTA}Subscription ID:${NC} $AZURE_SUBSCRIPTION_ID"
    echo -e "   ${MAGENTA}Tenant ID:${NC} $AZURE_TENANT_ID"
    echo -e "   ${MAGENTA}Default Location:${NC} $AZURE_DEFAULT_LOCATION"
    echo -e ""
    echo -e "   ${MAGENTA}Service Principal Credentials:${NC}"
    echo -e "   ${MAGENTA}Client ID:${NC} $ARM_CLIENT_ID"
    echo -e "   ${MAGENTA}Tenant ID:${NC} $ARM_TENANT_ID"
    echo -e "   ${MAGENTA}Client Secret:${NC} $ARM_CLIENT_SECRET"
}