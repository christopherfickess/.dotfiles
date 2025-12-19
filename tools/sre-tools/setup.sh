
#!/bin/bash

# Initialize directory variables if not already set
[[ -z "${__TOOLS_DIR}" ]] && __TOOLS_DIR="$HOME/.dotfiles/tools"
[[ -z "${__SRE_TOOLS_DIR}" ]] && __SRE_TOOLS_DIR="${__TOOLS_DIR}/sre-tools"
[[ -z "${__AWS_SRE_TOOLS_DIR}" ]] && __AWS_SRE_TOOLS_DIR="${__SRE_TOOLS_DIR}/aws"
[[ -z "${__AWS_CONNECT_FILE}" ]] && __AWS_CONNECT_FILE="${__AWS_SRE_TOOLS_DIR}/aws_connect.sh"
[[ -z "${__AWS_HELP_FILE}" ]] && __AWS_HELP_FILE="${__AWS_SRE_TOOLS_DIR}/help.sh"
[[ -z "${__BASH_CONFIG_DIR}" ]] && __BASH_CONFIG_DIR="${__TOOLS_DIR}/bash_config"
[[ -z "${__MATTERMOST_DIR}" ]] && __MATTERMOST_DIR="${__SRE_TOOLS_DIR}/mattermost"
[[ -z "${__MINIKUBE_DIR}" ]] && __MINIKUBE_DIR="${__SRE_TOOLS_DIR}/minikube"

function sre_tools() {
    # Handle command-line arguments first
    if [[ -n "${1}" ]]; then
        case "${1}" in
            -aws |--aws)
                __source_aws_functions
                echo -e "${GREEN}AWS functions loaded.${NC}"
                return 0
                ;;
            -m|--minikube)
                __source_minikube_functions
                echo -e "${GREEN}Minikube functions loaded.${NC}"
                return 0
                ;;
            -M|--mattermost)
                __source_mattermost_functions
                echo -e "${GREEN}Mattermost functions loaded.${NC}"
                return 0
                ;;
            -a|--all)
                echo -e "    ${MAGENTA}Setting up All...${NC}"
                __source_all_functions
                echo -e "${GREEN}All SRE tools setup completed.${NC}"
                return 0
                ;;
            -h|--help)
                help_sre_tools
                return 0
                ;;
            -l|--list)
                list_sre_tools
                return 0
                ;;
            -r|--remove)
                remove_sre_tools
                return 0
                ;;
            -u|--update)
                update_sre_tools
                return 0
                ;;
            -v|--version)
                show_sre_tools_version
                return 0
                ;;
            *)
                echo -e "${RED}Unknown option: ${1}${NC}"
                help_sre_tools
                return 1
                ;;
        esac
    fi
    
    # Interactive mode if no arguments provided
    echo -e "${CYAN}Which Functionality do you want to setup?${NC}"    
    echo -e "   ${YELLOW}1${NC}   | ${YELLOW}-m${NC}  | --minikube      ${GREEN}Minikube${NC}"
    echo -e "   ${YELLOW}2${NC}   | ${YELLOW}-M${NC}  | --mattermost    ${GREEN}Mattermost${NC}"
    echo -e "   ${YELLOW}3${NC}   | ${YELLOW}-a${NC}  | --all           ${GREEN}All${NC}"
    echo -e "   ${YELLOW}4${NC}   | ${YELLOW}-h${NC}  | --help          ${GREEN}Show Help${NC}"
    echo -e "   ${YELLOW}5${NC}   | ${YELLOW}-l${NC}  | --list          ${GREEN}List Available Tools${NC}"
    read -p "   Enter your choice: " choice

    case $choice in
        -aws|--aws)
            __source_aws_functions
            echo -e "${GREEN}AWS functions loaded.${NC}"
            ;;
        1|-m|--minikube)
            __source_minikube_functions
            echo -e "${GREEN}Minikube functions loaded.${NC}"
            ;;
        2|-M|--mattermost)
            __source_mattermost_functions
            echo -e "${GREEN}Mattermost functions loaded.${NC}"
            ;;
        3|-a|--all)
            __source_all_functions
            echo -e "${GREEN}All SRE tools setup completed.${NC}"
            ;;
        4|-h|--help)
            help_sre_tools
            ;;
        5|-l|--list)
            list_sre_tools
            ;;
        *)
            echo -e "${RED}Invalid choice.${NC}"
            return 1
            ;;
    esac
}

function __source_aws_functions() {
    local __AWS_SRE_TOOLS_SETUP_FILE="${__SRE_TOOLS_DIR}/aws/tools/setup.sh"
    
    if [ -f "${__AWS_SRE_TOOLS_SETUP_FILE}" ]; then 
        source "${__AWS_SRE_TOOLS_SETUP_FILE}" && __source_all_aws_functions
        echo -e "   ${GREEN}✓${NC} AWS functions"
    fi
    if [ -f "${__AWS_CONNECT_FILE}" ]; then 
        source "${__AWS_CONNECT_FILE}"
        echo -e "   ${GREEN}✓${NC} AWS connect functions"
    fi
    if [ -f "${__AWS_HELP_FILE}" ]; then 
        source "${__AWS_HELP_FILE}"
        echo -e "   ${GREEN}✓${NC} AWS help"
    fi
}

function __source_mattermost_functions() {
    local __MATTERMOST_FILE="${__MATTERMOST_DIR}/mattermost.sh"
    local __MATTERMOSTFED_FILE="${__MATTERMOST_DIR}/mattermostfed.sh"
    local __MATTERMOST_HELP_FILE="${__MATTERMOST_DIR}/help.sh"
    
    if [ -f "${__MATTERMOST_FILE}" ] && [ "${MATTERMOST}" == "TRUE" ]; then 
        source "${__MATTERMOST_FILE}"
        echo -e "   ${GREEN}✓${NC} Mattermost functions"
    fi
    if [ -f "${__MATTERMOSTFED_FILE}" ] && [ "${MATTERMOSTFED}" == "TRUE" ]; then 
        source "${__MATTERMOSTFED_FILE}"
        echo -e "   ${GREEN}✓${NC} Mattermost Fed functions"
    fi
    if [ -f "${__MATTERMOST_HELP_FILE}" ]; then 
        source "${__MATTERMOST_HELP_FILE}"
        echo -e "   ${GREEN}✓${NC} Mattermost help"
    fi
}

function __source_minikube_functions() {
    local __MINIKUBE_FUNCTIONS_FILE="${__MINIKUBE_DIR}/minikube_functions.sh"
    local __MINIKUBE_SETUP_FILE="${__MINIKUBE_DIR}/setup_minikube.sh"
    local __MINIKUBE_HELP_FILE="${__MINIKUBE_DIR}/help.sh"
    
    if [ -f "${__MINIKUBE_FUNCTIONS_FILE}" ]; then 
        source "${__MINIKUBE_FUNCTIONS_FILE}"
        echo -e "   ${GREEN}✓${NC} Minikube functions"
    fi
    if [ -f "${__MINIKUBE_SETUP_FILE}" ]; then 
        source "${__MINIKUBE_SETUP_FILE}"
        echo -e "   ${GREEN}✓${NC} Minikube setup"
    fi
    if [ -f "${__MINIKUBE_HELP_FILE}" ]; then 
        source "${__MINIKUBE_HELP_FILE}"
        echo -e "   ${GREEN}✓${NC} Minikube help"
    fi
}

function __source_all_functions() {
    echo -e "${MAGENTA}Loading all SRE tools...${NC}"
    __source_minikube_functions
    __source_mattermost_functions
}

function update_sre_tools() {
    echo -e "${CYAN}Updating SRE tools from dotfiles repository...${NC}"
    if [ -d "${__TOOLS_DIR}" ] && [ -d "$(dirname "${__TOOLS_DIR}")/.git" ]; then
        pushd "$(dirname "${__TOOLS_DIR}")" > /dev/null
        git pull
        popd > /dev/null
        echo -e "${GREEN}SRE tools updated successfully.${NC}"
        echo -e "${YELLOW}Note: You may need to reload your shell or run ${GREEN}bashrc${NC} to apply changes.${NC}"
    else
        echo -e "${RED}Could not find git repository. Manual update required.${NC}"
    fi
}

function show_sre_tools_version() {
    local version_file="${__TOOLS_DIR}/VERSION"
    if [ -f "${version_file}" ]; then
        echo -e "${CYAN}SRE Tools Version:${NC} $(cat "${version_file}")"
    else
        echo -e "${CYAN}SRE Tools Version:${NC} Unknown (no VERSION file found)"
    fi
    echo -e "${CYAN}Dotfiles Location:${NC} ${__TOOLS_DIR}"
}

[[ -f "${__TOOLS_DIR}/sre-tools/help.sh" ]] && source "${__TOOLS_DIR}/sre-tools/help.sh"