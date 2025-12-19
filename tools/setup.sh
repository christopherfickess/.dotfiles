


function sre_tools() {
    
    if [[ "${1}" == "-m" || "${1}" == "--minikube" ]]; then
        __source_minikube_functions
    fi
    if [[ "${1}" == "-a" || "${1}" == "--all" ]]; then
        echo -e "    ${MAGENTA}Setting up All...${NC}"
    fi  
    if [[ "${1}" == "-h" || "${1}" == "--help" ]]; then
        help_sre_tools
    fi
    if [[ "${1}" == "-l" || "${1}" == "--list" ]]; then
        list_sre_tools
    fi
    if [[ "${1}" == "-r" || "${1}" == "--remove" ]]; then
        remove_sre_tools    
    fi
    if [[ "${1}" == "-u" || "${1}" == "--update" ]]; then
        update_sre_tools
    fi
    if [[ "${1}" == "-v" || "${1}" == "--version" ]]; then
        show_sre_tools_version
    fi
    
    echo -e "Which Functionality do you want to setup?"    
    echo -e "   -m   | --minikube      ${YELLOW}Minikube${NC}"
    echo -e "   -d   | --docker        ${YELLOW}Docker${NC}"
    echo -e "   -k   | --kubernetes    ${YELLOW}Kubernetes${NC}"
    echo -e "   -aws | --aws           ${YELLOW}AWS${NC}"
    echo -e "   -m   | --mattermost    ${YELLOW}Mattermost${NC}"
    echo -e "   -A   | --all           ${YELLOW}All${NC}"
    echo -e "   -s   | --setup         ${YELLOW}Setup Environment${NC}"
    read -p "   Enter your choice: " choice

    case $choice in
        1)
            __source_minikube_functions
            ;;
        2)
            __source_docker_functions
            ;;
        3)
            __source_kubernetes_functions
            ;;
        4)
            __source_aws_functions
            ;;
        5)
            __source_mattermost_functions
            ;;
        6)
            __source_all_functions
            ;;
        *)
            echo -e "${RED}Invalid choice.${NC}"
            ;;
    esac

    echo -e "${GREEN}SRE tools setup completed.${NC}"
}

function __source_mattermost_functions() {
    __MATTERMOST_FILE="${__MATTERMOST_DIR}/mattermost.sh"
    __MATTERMOSTFED_FILE="${__MATTERMOST_DIR}/mattermostfed.sh"
    __MATTERMOST_HELP_FILE="${__MATTERMOST_DIR}/help.sh"
    if [ -f "${__MATTERMOST_FILE}" ]; then source "${__MATTERMOST_FILE}";  fi
    if [ -f "${__MATTERMOSTFED_FILE}" ]; then source "${__MATTERMOSTFED_FILE}";  fi
    if [ -f "${__MATTERMOST_HELP_FILE}" ]; then source "${__MATTERMOST_HELP_FILE}";  fi
}

function __source_minikube_functions() {
    __MINIKUBE_FUNCTIONS_FILE="${__KUBERNETES_FUNCTIONS_DIR}/minikube_functions.sh"
    __MINIKUBE_HELP_FILE="${__KUBERNETES_FUNCTIONS_DIR}/help.sh"
    if [ -f "${__MINIKUBE_FUNCTIONS_FILE}" ]; then source "${__MINIKUBE_FUNCTIONS_FILE}";  fi
    if [ -f "${__MINIKUBE_HELP_FILE}" ]; then source "${__MINIKUBE_HELP_FILE}";  fi
}

function __source_all_functions() {
    __source_aws_functions
    __source_docker_functions
    __source_kubernetes_functions
    __source_mattermost_functions
}