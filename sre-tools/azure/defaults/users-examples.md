

# Template User Login functions

This will give an example of how to use user functions to login to Azure and how to connect to Clusters to interact with Kubernetes resources easily

```bash
export __user_cluster_name__="dev-aks-cluster"
export __user_azure_resource_group__="rg-user-aks"

function user() {
    echo "Setting Azure environment for Dev..."

    az cloud set --name AzureCloud
    az account set --subscription "Dev Subscription"

    az account show --output table
}

function user.login() {
    echo "Logging into Azure (Dev)..."

    az login --use-device-code

    user
}

function user.connect() {
    echo "Connecting to AKS Dev cluster..."

    user
    __cluster_name__="${__user_cluster_name__}"
    __azure_resource_group__="${__user_azure_resource_group__}"
    __azure_cluster_connect__ "${__cluster_name__}"

    kubectl config current-context
}
```