#!/bin/bash

function myhelp_minikube() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN} Minikube Functions - Help${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if [[ "${SRE_TOOLS_VERBOSE:-false}" == "true" ]]; then
        __myhelp_minikube_advanced__
    else
        __myhelp_minikube_basic__
    fi

    echo ""
    if [[ "${SRE_TOOLS_VERBOSE:-false}" != "true" ]]; then
        echo -e "${__COMMAND_COLOR__}Tip:${NC} Set ${GREEN}SRE_TOOLS_VERBOSE=true${NC} for advanced commands"
    fi
}

function __myhelp_minikube_basic__() {
    echo -e "${BOLD}Common Commands:${NC}"
    echo -e "  ${__COMMAND_COLOR__}start_minikube_wsl${NC}          Start Minikube cluster"
    echo -e "  ${__COMMAND_COLOR__}stop_minikube${NC}               Stop Minikube cluster"
    echo -e "  ${__COMMAND_COLOR__}minikube_status${NC}             Show cluster status"
    echo -e "  ${__COMMAND_COLOR__}minikube_dashboard${NC}          Open Kubernetes dashboard"
    echo -e "  ${__COMMAND_COLOR__}minikube_service_url${NC}        Get service URL"
}

function __myhelp_minikube_advanced__() {
    __myhelp_minikube_basic__
    echo ""
    echo -e "${BOLD}Advanced Commands:${NC}"
    echo -e "  ${__COMMAND_COLOR__}delete_minikube${NC}             Delete Minikube cluster (destructive)"
    echo -e "  ${__COMMAND_COLOR__}minikube_addons${NC}             List/enable/disable addons"
    echo -e "  ${__COMMAND_COLOR__}minikube_cleanup${NC}            Clean up unused resources"
    echo -e "  ${__COMMAND_COLOR__}minikube_docker_env${NC}         Configure Docker to use Minikube"
    echo -e "  ${__COMMAND_COLOR__}minikube_load_image${NC}         Load Docker image into Minikube"
    echo -e "  ${__COMMAND_COLOR__}minikube_logs${NC}               View pod logs"
    echo -e "  ${__COMMAND_COLOR__}minikube_port_forward${NC}       Port forward a service"
    echo -e "  ${__COMMAND_COLOR__}minikube_shell${NC}              Open shell in Minikube node"
    echo -e "  ${__COMMAND_COLOR__}minikube_test_deployment${NC}    Test and inspect a deployment"
}
