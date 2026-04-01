#!/bin/bash

function myhelp_kubernetes() {
    echo -e "${__HEADER_COLOR__}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${__HEADER_COLOR__} Kubernetes Functions${NC}"
    echo -e "${__HEADER_COLOR__}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${BOLD}Common Commands:${NC}"
    echo -e "  ${__COMMAND_COLOR__}which_cluster${NC}                Shows which cluster you are currently connected to"
    echo -e "  ${__COMMAND_COLOR__}list_kubernetes_objects${NC}      List all Kubernetes objects in a specified namespace"
    echo -e "  ${__COMMAND_COLOR__}exec_into_pod${NC}                Execute a command inside a specified pod"
    echo ""
    echo -e "For more information: ${__INFO_COLOR__}https://kubernetes.io/docs/reference/kubectl/overview/${NC}"
}
