
function myhelp_azure() {
    echo -e "${__HEADER_COLOR__}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${__HEADER_COLOR__} Azure Functions${NC}"
    echo -e "${__HEADER_COLOR__}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if [[ ! -z "${__AZURE_FILE}" ]]; then
        __myhelp_azure_sre_tools__
    else
        __myhelp_azure__

        echo ""
        echo -e "${__HEADER_COLOR__}Azure Display Commands:${NC}"
        __myhelp_azure_display__

        echo ""
        echo -e "${__HEADER_COLOR__}Azure Getter Commands:${NC}"
        __myhelp_azure_getters__

        echo ""
        echo -e "${__HEADER_COLOR__}Azure Setter Commands:${NC}"
        __myhelp_azure_setters__

        echo ""
        echo -e "${__HEADER_COLOR__}Safe Learning Commands:${NC}"
        __myhelp_azure_safe_learning_commands__

        echo ""
        echo -e "${__HEADER_COLOR__}Startup Checklist:${NC}"
        __myhelp_azure_startup_checklist__
    fi

    echo ""
    if [[ "${SRE_TOOLS_VERBOSE:-false}" != "true" ]]; then
        echo -e "${__COMMAND_COLOR__}Tip:${NC} Set ${__DETAILS_COLOR__}SRE_TOOLS_VERBOSE=true${NC} or use ${__DETAILS_COLOR__}myhelp -v${NC} for all Azure commands"
    fi
    echo ""
    echo -e "For more information: ${__INFO_COLOR__}https://docs.microsoft.com/en-us/cli/azure/${NC}"
}

function __myhelp_azure_sre_tools__() {
    if [[ "${SRE_TOOLS_VERBOSE:-false}" == "true" ]]; then
        __myhelp_azure_advanced__
    else
        __myhelp_azure_basic__
    fi
}

function __myhelp_azure_basic__() {
    echo -e "${BOLD}Common Commands:${NC}"
    echo -e "  ${__COMMAND_COLOR__}azure_auth_update${NC}            Update Azure credentials"
    echo -e "  ${__COMMAND_COLOR__}azure_profile_switch${NC}         Switch Azure profiles"
    echo -e "  ${__COMMAND_COLOR__}azure.cluster.connect${NC}        Connect to an AKS cluster"
    echo -e "  ${__COMMAND_COLOR__}az account show${NC}              Show current Azure account details"
    echo -e "  ${__COMMAND_COLOR__}az account list${NC}              List all Azure accounts"
    echo -e "  ${__COMMAND_COLOR__}az group list${NC}                List resource groups"
}

function __myhelp_azure_advanced__() {
    __myhelp_azure_basic__
    echo ""
    echo -e "${BOLD}Advanced Learning Commands:${NC}"
    echo -e "  ${__COMMAND_COLOR__}az cloud show${NC}                Show the current Azure cloud"
    echo -e "  ${__COMMAND_COLOR__}az resource list${NC}             List resources in subscription"
    echo -e "  ${__COMMAND_COLOR__}az role assignment list${NC}      List role assignments"
    echo ""
    echo -e "${BOLD}Setup Checklist:${NC}"
    echo -e "  ${__COMMAND_COLOR__}az login${NC}                     Log in to Azure"
    echo -e "  ${__COMMAND_COLOR__}az account list --output table${NC}        List accounts (table format)"
    echo -e "  ${__COMMAND_COLOR__}az account set --subscription <name>${NC}  Set active subscription"
    echo -e "  ${__COMMAND_COLOR__}az group list --output table${NC}          List resource groups (table)"
}

function __myhelp_azure__() {
    echo -e "${BOLD}Common Commands:${NC}"
    echo -e "  ${__COMMAND_COLOR__}azure_auth_update${NC}            Update Azure credentials"
    echo -e "  ${__COMMAND_COLOR__}azure_profile_switch${NC}         Switch Azure profiles"
    echo -e "  ${__COMMAND_COLOR__}azure.cluster.connect${NC}        Connect to an AKS cluster"
    echo -e "  ${__COMMAND_COLOR__}myhelp_azure${NC}                 Show Azure functions help"
}

function __myhelp_azure_safe_learning_commands__(){
    echo -e "  ${__COMMAND_COLOR__}az cloud show${NC}                Show the current Azure cloud"
    echo -e "  ${__COMMAND_COLOR__}az account show${NC}              Show current Azure account details"
    echo -e "  ${__COMMAND_COLOR__}az account list${NC}              List all Azure accounts"
    echo -e "  ${__COMMAND_COLOR__}az group list${NC}                List resource groups in the current subscription"
    echo -e "  ${__COMMAND_COLOR__}az resource list${NC}             List resources in the current subscription"
    echo -e "  ${__COMMAND_COLOR__}az role assignment list${NC}      List role assignments for the current subscription"
}

function __myhelp_azure_startup_checklist__(){
    echo -e "  ${__COMMAND_COLOR__}az cloud show${NC}                            Show the current Azure cloud"
    echo -e "  ${__COMMAND_COLOR__}az login${NC}                                 Log in to Azure"
    echo -e "  ${__COMMAND_COLOR__}az account list --output table${NC}           List all Azure accounts in a table format"
    echo -e "  ${__COMMAND_COLOR__}az account set --subscription \"<name>\"${NC}    Set the active subscription"
    echo -e "  ${__COMMAND_COLOR__}az account show${NC}                          Show current Azure account details"
    echo -e "  ${__COMMAND_COLOR__}az group list --output table${NC}             List resource groups in the current subscription in a table format"
}


function __myhelp_azure_display__(){
    echo -e "  ${__COMMAND_COLOR__}azure.display.subscription.details${NC}           Show details of the current Azure subscription"
    echo -e "  ${__COMMAND_COLOR__}azure.display.subscription.id${NC}                Show the current Azure subscription ID"
    echo -e "  ${__COMMAND_COLOR__}azure.display.sp.id.from.name <sp-name>${NC}      Get the App ID of a service principal by name"
    echo -e "  ${__COMMAND_COLOR__}azure.display.sp.role.assignments <sp-name>${NC}  Show role assignments for a service principal"
    echo -e "  ${__COMMAND_COLOR__}azure.display.sp.credentials <sp-name>${NC}       Show credentials for a service principal"
    echo -e "  ${__COMMAND_COLOR__}azure.assign.role.sp${NC}                         Assign Storage Blob Data Contributor and Contributor roles to the SP on the storage account and resource group"
}


function __myhelp_azure_getters__() {
    echo -e "  ${__COMMAND_COLOR__}azure.get.aks_credentials <cluster_name> <rg>${NC}   Get AKS cluster credentials and update kubeconfig"
    echo -e "  ${__COMMAND_COLOR__}azure.get.aks_roles <cluster_name> <rg>${NC}         Get role assignments for an AKS cluster"
    echo -e "  ${__COMMAND_COLOR__}azure.get.details${NC}                               Get details about the Azure environment"
    echo -e "  ${__COMMAND_COLOR__}azure.get.member_groups <user_email>${NC}            Get Azure AD group assignments for a user"
    echo -e "  ${__COMMAND_COLOR__}azure.get.role_assignments <user_email>${NC}         Get role assignments for a user"
    echo -e "  ${__COMMAND_COLOR__}azure.get.subscription_id${NC}                       Get the current Azure subscription ID"
    echo -e "  ${__COMMAND_COLOR__}azure.get.tenant_id${NC}                             Get the current Azure tenant ID"
}


function __myhelp_azure_setters__() {
    echo -e "  ${__COMMAND_COLOR__}azure.set.subscription <subscription-name>${NC}      Set the active Azure subscription by name"
}
