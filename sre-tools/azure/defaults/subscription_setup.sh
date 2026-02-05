#!/bin/bash

# -------------------------------------------
# Colors for output
# -------------------------------------------
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
MAGENTA="\033[0;35m"
NC="\033[0m"

# -------------------------------------------
# Step 0: Show current account and subscription
# -------------------------------------------
function azure_show_account() {
    echo -e "${GREEN}Current Azure account and subscription:${NC}"
    az account show
}

function azure_get_subscription_id() {
    local __sub_id__
    __sub_id__=$(az account show --query id -o tsv)
    echo "$__sub_id__"
}

# -------------------------------------------
# Step 1: Create a Service Principal (SP)
# -------------------------------------------
function azure_create_service_principal() {
    local __sp_name__="${1:-terraform-sp-chris}"

    echo -e "${GREEN}Creating Service Principal: $__sp_name__${NC}"
    az ad sp create-for-rbac --name "$__sp_name__" --skip-assignment -o json
}

# -------------------------------------------
# Step 2: Get SP object ID (needed for role assignments)
# -------------------------------------------
function azure_get_sp_object_id() {
    local __appId__="$1"
    if [ -z "$__appId__" ]; then
        echo -e "${RED}appId is required${NC}"
        return 1
    fi
    az ad sp show --id "$__appId__" --query id -o tsv
}

# -------------------------------------------
# Step 3: Get Storage Account Resource ID
# -------------------------------------------
function azure_get_storage_account_id() {
    local __sa_name__="$1"
    local __rg_name__="$2"

    if [ -z "$__sa_name__" ] || [ -z "$__rg_name__" ]; then
        echo -e "${RED}Storage account name and resource group required${NC}"
        return 1
    fi

    az storage account show \
        --name "$__sa_name__" \
        --resource-group "$__rg_name__" \
        --query id -o tsv
}

# -------------------------------------------
# Step 4: Assign Storage Blob Data Contributor role to SP
# -------------------------------------------
function azure_assign_storage_role() {
    local __sp_object_id__="$1"
    local __container_scope__="$2"

    if [ -z "$__sp_object_id__" ] || [ -z "$__container_scope__" ]; then
        echo -e "${RED}SP object ID and container scope required${NC}"
        return 1
    fi

    echo -e "${GREEN}Assigning Storage Blob Data Contributor role...${NC}"
    az role assignment create \
        --assignee "$__sp_object_id__" \
        --role "Storage Blob Data Contributor" \
        --scope "$__container_scope__"
}

# -------------------------------------------
# Step 5: Reset SP credentials (optional)
# -------------------------------------------
function azure_reset_sp_credentials() {
    local __appId__="$1"
    local __name__="${2:-terraform-backend}"

    if [ -z "$__appId__" ]; then
        echo -e "${RED}appId required${NC}"
        return 1
    fi

    echo -e "${GREEN}Resetting credentials for SP $__appId__...${NC}"
    az ad sp credential reset --id "$__appId__" --name "$__name__" --years 1 -o json
}

# -------------------------------------------
# Step 6: Set environment variables for Terraform
# -------------------------------------------
function azure_export_tf_env_vars() {
    local __appId__="$1"
    local __password__="$2"
    local __tenant__="$3"
    local __subscription__="$4"

    export ARM_CLIENT_ID="$__appId__"
    export ARM_CLIENT_SECRET="$__password__"
    export ARM_TENANT_ID="$__tenant__"
    export ARM_SUBSCRIPTION_ID="$__subscription__"

    echo -e "${GREEN}Terraform environment variables set:${NC}"
    echo "ARM_CLIENT_ID=$ARM_CLIENT_ID"
    echo "ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET"
    echo "ARM_TENANT_ID=$ARM_TENANT_ID"
    echo "ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID"
}

# -------------------------------------------
# Step 7: Show Storage container info
# -------------------------------------------
function show_storage_container() {
    local __sa_name__="$1"
    local __container__="$2"
    az storage container show --name "$__container__" --account-name "$__sa_name__"
}

# -------------------------------------------
# Example usage: full flow
# -------------------------------------------
function full_flow() {
    local __sp_name__="${1:-terraform-sp-chris}"
    local __rg_name__="$2"
    local __sa_name__="$3"
    local __container__="$4"

    # 0 - Account info
    azure_show_account
    local __subscription_id__
    __subscription_id__=$(azure_get_subscription_id)

    # 1 - Create SP
    local __sp_json__
    __sp_json__=$(azure_create_service_principal "$__sp_name__")
    local __appId__ __password__ __tenant__
    __appId__=$(echo "$__sp_json__" | jq -r .appId)
    __password__=$(echo "$__sp_json__" | jq -r .password)
    __tenant__=$(echo "$__sp_json__" | jq -r .tenant)

    # 2 - Get SP object ID
    local __sp_object_id__
    __sp_object_id__=$(azure_get_sp_object_id "$__appId__")
    # 3 - Storage account resource ID
    local __sa_id__
    __sa_id__=$(azure_get_storage_account_id "$__sa_name__" "$__rg_name__")
    # 4 - Assign Storage role
    local __container_scope__="${__sa_id__}/blobServices/default/containers/$__container__"
    azure_assign_storage_role "$__sp_object_id__" "$__container_scope__"

    # 6 - Export env variables
    azure_export_tf_env_vars "$__appId__" "$__password__" "$__tenant__" "$__subscription_id__"
    echo -e "${GREEN}Full SP setup completed for Terraform backend!${NC}"
}

