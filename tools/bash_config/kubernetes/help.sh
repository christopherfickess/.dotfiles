
function myhelp_kubernetes() {
    echo -e ""
    echo -e "Description:"
    echo -e "------------------------------------------------------------------------------------------------------"
    echo -e "${MAGENTA}This function provides a list of useful Kubernetes commands to help users "
    echo -e "   navigate and manage their Kubernetes clusters effectively.${NC}"
    echo -e ""
    echo -e "Kubernetes Commands:"
    echo -e "------------------------------------------------------------------------------------------------------"
    echo -e "     ${YELLOW}which_cluster${NC}                   - Shows which cluster you are currently connected to"
    echo -e "     ${YELLOW}list_kubernetes_objects${NC}         - List all Kubernetes objects in a specified namespace"
    echo -e "     ${YELLOW}exec_into_pod${NC}                   - Execute a command inside a specified pod"
    echo -e ""
    echo -e "For more information, visit: https://kubernetes.io/docs/reference/kubectl/overview/"
}