
function azure_cluster_connect(){
    if [[ -z "${1}" ]]; then 
        echo -e "${RED}Add the cluster name to proceed! ${NC}"
        __azure_eks_cluster_options__
        return
    elif [[ ! -z "${1}" ]]; then
        local __cluster_name__="${1}"
    else
        __azure_eks_cluster_options__
        return
    fi

    __azure_cluster_connect__ "${__cluster_name__}"
}

function __azure_eks_cluster_options__(){
    echo -e "Usage: azure_cluster_connect [options] <cluster-name>"
    echo
    echo -e "Options:"
    echo -e "  -h, --help            Show this help message and exit"
    echo
    echo -e "Example:"
    echo -e "  azure_cluster_connect my-aks-cluster"
    echo
}

function __azure_cluster_connect__(){
    if [[ -z "${1}" && -z "${2}" ]]; then 
        echo -e "${RED}Add the cluster name \$1 and \$2 for resource group to proceed! ${NC}"
        __azure_eks_cluster_options__
        return
    elif [[ ! -z "${1}" && ! -z "${2}" ]]; then
        local __cluster_name__="${1}"
        local __resource_group__="${2}"
    else
        __azure_eks_cluster_options__
        return
    fi
    
    az aks get-credentials \
        --resource-group "${__azure_resource_group__}" \
        --name "${__cluster_name__}" \
        --overwrite-existing
    local __cluster_exit_code__=$?

    if [[ ${__cluster_exit_code__} -ne 0 ]]; then
        echo -e "   ${RED}${__failed_box}${NC}   Failed to connect to AKS cluster: ${YELLOW}${__cluster_name__}${NC}"
        echo
        return
    else
        echo -e "   ${GREEN}${__check_mark_box}${NC}   Successfully connected to AKS cluster: ${YELLOW}${__cluster_name__}${NC}"
        echo
    fi
}