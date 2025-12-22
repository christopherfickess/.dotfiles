#!/bin/bash

# Minikube utility functions for local Kubernetes development and testing

function start_minikube_wsl() {
    echo -e "${GREEN}Starting Minikube in WSL...${NC}"

    if ! command -v minikube > /dev/null; then
        echo -e "${RED}Minikube not found. Please install it first.${NC}"
        return 1
    fi
    if ! command -v docker > /dev/null; then
        echo -e "${RED}Docker not found. Please install it first.${NC}"
        return 1
    fi
    
    local driver="${1:-docker}"
    local memory="${2:-4096}"
    local cpus="${3:-2}"
    
    echo -e "${CYAN}Starting Minikube with driver: ${driver}, memory: ${memory}MB, CPUs: ${cpus}${NC}"
    minikube start --driver="${driver}" --memory="${memory}" --cpus="${cpus}"
    minikube status
    echo -e "${GREEN}Minikube started successfully.${NC}"
}

function stop_minikube() {
    echo -e "${YELLOW}Stopping Minikube...${NC}"
    if minikube status &>/dev/null; then
        minikube stop
        echo -e "${GREEN}Minikube stopped successfully.${NC}"
    else
        echo -e "${YELLOW}Minikube is not running.${NC}"
    fi
}

function delete_minikube() {
    echo -e "${RED}WARNING: This will delete the Minikube cluster and all its data!${NC}"
    read -p "Are you sure? (yes/no): " confirm
    if [[ "${confirm}" == "yes" ]]; then
        minikube delete
        echo -e "${GREEN}Minikube cluster deleted.${NC}"
    else
        echo -e "${CYAN}Operation cancelled.${NC}"
    fi
}

function minikube_status() {
    if command -v minikube > /dev/null; then
        minikube status
        echo ""
        echo -e "${CYAN}Minikube Info:${NC}"
        minikube profile list
    else
        echo -e "${RED}Minikube is not installed.${NC}"
        return 1
    fi
}

function minikube_dashboard() {
    echo -e "${GREEN}Opening Minikube dashboard...${NC}"
    echo -e "${YELLOW}Press Ctrl+C to stop the dashboard${NC}"
    minikube dashboard
}

function minikube_service_url() {
    if [ -z "${1}" ]; then
        echo -e "${RED}Usage: minikube_service_url <service-name> [namespace]${NC}"
        echo -e "${YELLOW}Example: minikube_service_url my-service default${NC}"
        return 1
    fi
    
    local service_name="${1}"
    local namespace="${2:-default}"
    
    if kubectl get service "${service_name}" -n "${namespace}" &>/dev/null; then
        local url=$(minikube service "${service_name}" -n "${namespace}" --url)
        echo -e "${GREEN}Service URL: ${url}${NC}"
        echo "${url}" | xclip -selection clipboard 2>/dev/null || echo "${url}" | pbcopy 2>/dev/null || echo -e "${YELLOW}URL copied to clipboard (if supported)${NC}"
    else
        echo -e "${RED}Service '${service_name}' not found in namespace '${namespace}'${NC}"
        return 1
    fi
}

function minikube_port_forward() {
    if [ -z "${1}" ] || [ -z "${2}" ]; then
        echo -e "${RED}Usage: minikube_port_forward <service-name> <local-port>:<remote-port> [namespace]${NC}"
        echo -e "${YELLOW}Example: minikube_port_forward my-service 8080:80 default${NC}"
        return 1
    fi
    
    local service_name="${1}"
    local port_mapping="${2}"
    local namespace="${3:-default}"
    
    echo -e "${GREEN}Port forwarding ${service_name} ${port_mapping} in namespace ${namespace}...${NC}"
    echo -e "${YELLOW}Press Ctrl+C to stop port forwarding${NC}"
    kubectl port-forward "service/${service_name}" "${port_mapping}" -n "${namespace}"
}

function minikube_addons() {
    local action="${1:-list}"
    
    case "${action}" in
        list|ls)
            echo -e "${CYAN}Available Minikube Addons:${NC}"
            minikube addons list
            ;;
        enable)
            if [ -z "${2}" ]; then
                echo -e "${RED}Usage: minikube_addons enable <addon-name>${NC}"
                echo -e "${YELLOW}Example: minikube_addons enable ingress${NC}"
                return 1
            fi
            echo -e "${GREEN}Enabling addon: ${2}${NC}"
            minikube addons enable "${2}"
            ;;
        disable)
            if [ -z "${2}" ]; then
                echo -e "${RED}Usage: minikube_addons disable <addon-name>${NC}"
                return 1
            fi
            echo -e "${YELLOW}Disabling addon: ${2}${NC}"
            minikube addons disable "${2}"
            ;;
        *)
            echo -e "${RED}Unknown action: ${action}${NC}"
            echo -e "Usage: minikube_addons [list|enable|disable] [addon-name]"
            return 1
            ;;
    esac
}

function minikube_shell() {
    echo -e "${GREEN}Opening shell in Minikube node...${NC}"
    minikube ssh
}

function minikube_docker_env() {
    echo -e "${CYAN}Setting up Docker environment for Minikube...${NC}"
    eval $(minikube docker-env)
    echo -e "${GREEN}Docker environment configured. You can now use 'docker' commands with Minikube.${NC}"
    echo -e "${YELLOW}To unset, run: eval \$(minikube docker-env -u)${NC}"
}

function minikube_load_image() {
    if [ -z "${1}" ]; then
        echo -e "${RED}Usage: minikube_load_image <image-name>${NC}"
        echo -e "${YELLOW}Example: minikube_load_image myapp:latest${NC}"
        return 1
    fi
    
    local image="${1}"
    echo -e "${GREEN}Loading image ${image} into Minikube...${NC}"
    minikube image load "${image}"
    echo -e "${GREEN}Image loaded successfully.${NC}"
}

function minikube_test_deployment() {
    if [ -z "${1}" ]; then
        echo -e "${RED}Usage: minikube_test_deployment <deployment-name> [namespace]${NC}"
        return 1
    fi
    
    local deployment="${1}"
    local namespace="${2:-default}"
    
    echo -e "${CYAN}Testing deployment: ${deployment} in namespace: ${namespace}${NC}"
    
    # Check if deployment exists
    if ! kubectl get deployment "${deployment}" -n "${namespace}" &>/dev/null; then
        echo -e "${RED}Deployment '${deployment}' not found in namespace '${namespace}'${NC}"
        return 1
    fi
    
    # Check deployment status
    echo -e "${YELLOW}Deployment Status:${NC}"
    kubectl get deployment "${deployment}" -n "${namespace}"
    
    # Check pods
    echo -e "\n${YELLOW}Pod Status:${NC}"
    kubectl get pods -l app="${deployment}" -n "${namespace}" 2>/dev/null || kubectl get pods -n "${namespace}"
    
    # Check services
    echo -e "\n${YELLOW}Service Status:${NC}"
    kubectl get svc -n "${namespace}" | grep "${deployment}" || echo "No services found for ${deployment}"
}

function minikube_logs() {
    if [ -z "${1}" ]; then
        echo -e "${RED}Usage: minikube_logs <pod-name> [namespace] [--follow]${NC}"
        return 1
    fi
    
    local pod_name="${1}"
    local namespace="${2:-default}"
    local follow_flag="${3}"
    
    if [[ "${2}" == "--follow" ]] || [[ "${3}" == "--follow" ]]; then
        follow_flag="--follow"
        namespace="${2}"
        if [[ "${2}" == "--follow" ]]; then
            namespace="default"
        fi
    fi
    
    echo -e "${CYAN}Fetching logs for pod: ${pod_name} in namespace: ${namespace}${NC}"
    kubectl logs "${pod_name}" -n "${namespace}" ${follow_flag}
}

function minikube_cleanup() {
    echo -e "${YELLOW}Cleaning up Minikube resources...${NC}"
    
    # Delete all pods in default namespace (except system pods)
    kubectl delete pods --all --field-selector=status.phase!=Running 2>/dev/null || true
    
    # Clean up completed jobs
    kubectl delete jobs --all 2>/dev/null || true
    
    # Clean up old replicasets
    kubectl delete rs --all --field-selector=status.replicas=0 2>/dev/null || true
    
    echo -e "${GREEN}Cleanup completed.${NC}"
}

function minikube_help() {
    echo -e "${CYAN}Minikube Functions:${NC}"
    echo -e "------------------------------------------------------------------------------------------------------"
    echo -e "   ${YELLOW}delete_minikube${NC}           - Delete Minikube cluster (destructive)"
    echo -e "   ${YELLOW}minikube_addons${NC}           - List/enable/disable Minikube addons"
    echo -e "   ${YELLOW}minikube_cleanup${NC}          - Clean up unused resources"
    echo -e "   ${YELLOW}minikube_dashboard${NC}        - Open Minikube dashboard"
    echo -e "   ${YELLOW}minikube_docker_env${NC}       - Configure Docker to use Minikube"
    echo -e "   ${YELLOW}minikube_help${NC}             - Show this help message"
    echo -e "   ${YELLOW}minikube_load_image${NC}       - Load Docker image into Minikube"
    echo -e "   ${YELLOW}minikube_logs${NC}             - View pod logs"
    echo -e "   ${YELLOW}minikube_port_forward${NC}     - Port forward a service"
    echo -e "   ${YELLOW}minikube_service_url${NC}      - Get service URL and open in browser"
    echo -e "   ${YELLOW}minikube_shell${NC}            - Open shell in Minikube node"
    echo -e "   ${YELLOW}minikube_status${NC}           - Show Minikube status and info"
    echo -e "   ${YELLOW}minikube_test_deployment${NC}  - Test and inspect a deployment"
    echo -e "   ${YELLOW}start_minikube_wsl${NC}        - Start Minikube cluster (WSL/Linux optimized)"
    echo -e "   ${YELLOW}stop_minikube${NC}             - Stop Minikube cluster"
}