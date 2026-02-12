
function myhelp_azure() {
    
    echo -e "Azure Functions:"
    echo -e "------------------------------------------------------------------------------------------------------"

    if [[ ! -z "${__AZURE_FILE}" ]]; then
        __myhelp_azure_sre_tools__
    else 
        __myhelp_azure__

        echo -e ""
        echo -e "Azure Display Commands:"
        echo -e "------------------------------------------------------------------------------------------------------"
        __myhelp_azure_display__

        echo -e ""
        echo -e "Azure Getter Commands:"
        echo -e "------------------------------------------------------------------------------------------------------"
        __myhelp_azure_getters__

        echo -e ""
        echo -e "Azure Setters Commands:"
        echo -e "------------------------------------------------------------------------------------------------------"
        __myhelp_azure_setters__

        echo -e ""
        echo -e "Safe Learning Commands:"
        echo -e "------------------------------------------------------------------------------------------------------"
        __myhelp_azure_safe_learning_commands__ 

        echo -e ""
        echo -e "Startup Checklist:"
        echo -e "------------------------------------------------------------------------------------------------------"
        __myhelp_azure_startup_checklist__
    fi
}

function __myhelp_azure__() {
    echo -e "     ${YELLOW}azure_auth_update${NC}               - Update Azure credentials"
    echo -e "     ${YELLOW}azure_profile_switch${NC}            - Switch Azure profiles"
    echo -e "     ${YELLOW}azure.cluster.connect${NC}           - Connect to an AKS cluster"
    echo -e "     ${YELLOW}myhelp_azure${NC}                    - Show Azure functions help"
}

function __myhelp_azure_safe_learning_commands__(){
    echo -e "     ${YELLOW}az cloud show${NC}                   - Show the current Azure cloud"
    echo -e "     ${YELLOW}az account show${NC}                 - Show current Azure account details"
    echo -e "     ${YELLOW}az account list${NC}                 - List all Azure accounts"
    echo -e "     ${YELLOW}az group list${NC}                   - List resource groups in the current subscription"
    echo -e "     ${YELLOW}az resource list${NC}                - List resources in the current subscription"
    echo -e "     ${YELLOW}az role assignment list${NC}         - List role assignments for the current subscription"
}

function __myhelp_azure_startup_checklist__(){
    echo -e "     ${YELLOW}az cloud show${NC}                               - Show the current Azure cloud"
    echo -e "     ${YELLOW}az login${NC}                                    - Log in to Azure"
    echo -e "     ${YELLOW}az account list --output table${NC}              - List all Azure accounts in a table format"
    echo -e "     ${YELLOW}az account set --subscription \"<name>\"${NC}    - Set the active subscription"
    echo -e "     ${YELLOW}az account show${NC}                             - Show current Azure account details"
    echo -e "     ${YELLOW}az group list --output table${NC}                - List resource groups in the current subscription in a table format"
}