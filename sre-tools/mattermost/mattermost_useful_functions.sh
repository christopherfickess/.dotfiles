
function mattermost_rollout() {
    # Rollout restart all mattermost deployments in all namespaces
    if [ -z "$1" ]; then
        echo -e "${YELLOW}What namespace do you wish to target?  ${NC}"
        kubectl get ns | grep mattermost
        read -p "   :>  " __namespace__
        __namespace__="${__namespace__}"
    else
        echo -e "${YELLOW}Rolling out restart for all Mattermost deployments in namespace: ${1}...${NC}"
    fi

    kubectl -n "${1}" rollout restart deployment
}