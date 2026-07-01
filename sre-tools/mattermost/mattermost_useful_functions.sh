
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

function mattermost_desktop_app_clear_cache() {
    # Clear the Mattermost desktop app cache
    if [[ "$OSTYPE" == "darwin"* ]]; then
        rm -rf ~/Library/Containers/Mattermost.Desktop/Data/Library/Application\ Support/Mattermost/Cache
        rm -rf ~/Library/Containers/Mattermost.Desktop/Data/Library/Application\ Support/Mattermost/GPUCache
        echo -e "${YELLOW}Mattermost desktop app cache cleared on macOS.${NC}"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        rm -rf ~/.config/Mattermost
        echo -e "${YELLOW}Mattermost desktop app cache cleared on Linux.${NC}"
    else
        echo -e "${RED}Unsupported OS for clearing Mattermost desktop app cache.${NC}"
    fi
}