
# This page needs help

# Template User Login functions

This will give an example of how to use user functions to login to Azure and how to connect to Clusters to interact with Kubernetes resources easily

```bash
function azure.sandbox.env() {
    echo -e "Setting Azure environment for ${CYAN}Sandbox...${NC}"
    export __email__="christopher.fickess@mattermost.com"
    export __aks_cluster_name__="mattermost-dev-chris-aks"
    export __aks_resource_group__="chrisfickess-tfstate-azk"

    export AZURE_DEFAULT_LOCATION="eastus"
    local SUBSCRIPTION_NAME="name-of-development-subscription"
    
    export ARM_CLIENT_ID="<client-id-from-sp>"
    export ARM_CLIENT_SECRET="<client-secret-from-sp>"
    
    export __sandbox_cluster_name__="mattermost-dev-chris-aks"
}

function azure.sandbox() {
    azure.sandbox.env;
    
    # Function in setters.sh file to set subscription
    azure.set.subscription "$SUBSCRIPTION_NAME"

    # Function in getter.sh file to display subscription and tenant info
    azure.get.subscription_id
    azure.get.tenant_id
   
    # Function at bottom of users.sh file to display environment info
    azure.display.env
}



function azure.dev.terraform.accesskey() {
    __resource_group__="name-of-resource-group"
    __storage_account__="name-of-storage-account"
    echo -e "Setting Azure environment for ${CYAN}Development Terraform Access Key...${NC}"
    export ACCOUNT_KEY=$(az storage account keys list \
        --resource-group "$__resource_group__" \
        --account-name "$__storage_account__" \
        --query '[0].value' -o tsv)

    echo -e "   ${MAGENTA}Terraform Access Key:${NC} ${ACCOUNT_KEY}"
}
```

# Create Service Principal and Terraform Access Key

This function is in the create.sh file and can be used to create a service principal with the necessary permissions for Terraform to manage resources in Azure, as well as to create a storage container for Terraform state files.

To create a service principal and set up the environment for Terraform, you can run:

```bash
azure.create.tf.sp "my-terraform-sp" "my-resource-group" "my-storage-account" "my-container"
azure.sandbox.terraform.accesskey
```
 
Or

Create a service principal with default values:

```bash
function azure.create.sandbox.service.principal() {
    export __app_name__="terraform-sp-chris"
    export __rg_name__="chrisfickess-tfstate-azk"
    export __storage_account__="tfstatechrisfickess"
    export __container_name__="azure-azk-tfstate"
    azure.create.tf.sp
}

azure.sandbox.terraform.accesskey
```