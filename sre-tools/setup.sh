
#!/bin/bash

# Initialize directory variables if not already set
[[ -z "${__TOOLS_DIR}" ]] && __TOOLS_DIR="$HOME/.dotfiles/tools"
[[ -z "${__SRE_TOOLS_DIR}" ]] && __SRE_TOOLS_DIR="${__TOOLS_DIR}/sre-tools"
[[ -z "${__AWS_SRE_TOOLS_DIR}" ]] && __AWS_SRE_TOOLS_DIR="${__SRE_TOOLS_DIR}/aws"
[[ -z "${__AWS_CONNECT_FILE}" ]] && __AWS_CONNECT_FILE="${__AWS_SRE_TOOLS_DIR}/defaults/aws_connect.sh"
[[ -z "${__AWS_HELP_FILE}" ]] && __AWS_HELP_FILE="${__AWS_SRE_TOOLS_DIR}/help.sh"
[[ -z "${__BASH_CONFIG_DIR}" ]] && __BASH_CONFIG_DIR="${__TOOLS_DIR}/bash_config"
[[ -z "${__MATTERMOST_DIR}" ]] && __MATTERMOST_DIR="${__SRE_TOOLS_DIR}/mattermost"
[[ -z "${__MINIKUBE_DIR}" ]] && __MINIKUBE_DIR="${__SRE_TOOLS_DIR}/minikube"
[[ -z "${__GO_TOOLS_DIR}" ]] && __GO_TOOLS_DIR="${__SRE_TOOLS_DIR}/go"
[[ -z "${__PYTHON_TOOLS_DIR}" ]] && __PYTHON_TOOLS_DIR="${__SRE_TOOLS_DIR}/python"

function sre_tools() {
    # Handle command-line arguments first
    [[ -n "${1}" ]] && choice="${1}" && __sre_tools_menu_logic && return $?
    
    # Interactive mode if no arguments provided
    echo -e "${CYAN}Which Functionality do you want to setup?${NC}"    
    echo -e "   ${YELLOW}-a${NC}    | --all           ${CYAN}All${NC}"
    echo -e "   ${YELLOW}-aws${NC}  | --aws           ${CYAN}AWS Functions${NC}"
    echo -e "   ${YELLOW}-g${NC}    | --go            ${CYAN}Go Tools${NC}"
    echo -e "   ${YELLOW}-l${NC}    | --list          ${CYAN}List Available Tools${NC}"
    echo -e "   ${YELLOW}-h${NC}    | --help          ${CYAN}Show Help${NC}"
    echo -e "   ${YELLOW}-M${NC}    | --mattermost    ${CYAN}Mattermost${NC}"
    echo -e "   ${YELLOW}-m${NC}    | --minikube      ${CYAN}Minikube${NC}"
    echo -e "   ${YELLOW}-p${NC}    | --python        ${CYAN}Python Tools${NC}"
    echo -e "   ${YELLOW}-u${NC}    | --update        ${CYAN}Update SRE Tools${NC}"
    echo -e "   ${YELLOW}-v${NC}    | --version       ${CYAN}Show SRE Tools Version${NC}"
    echo -e ""

    read -p "   Enter your choice: " choice
    
    __sre_tools_menu_logic
}

function __sre_tools_menu_logic(){
    case $choice in
        -a|--all)
            __source_all_functions
            ;;
        -aws|--aws)
            __source_aws_functions
            ;;
        -g|--go)
            __source_go_functions
            ;;
        -h|--help)
            help_sre_tools
            ;;
        -l|--list)
            list_sre_tools
            ;;
        -M|--mattermost)
            __source_mattermost_functions
            ;;
        -m|--minikube)
            __source_minikube_functions
            ;;
        -p|--python)
            __source_python_functions
            ;;
        -u|--update)
            reload_sre_tools
            unset choice
            return 0
            ;;
        *)
            echo -e "${RED}Invalid choice.${NC}"
            unset choice
            return 1
            ;;
        
    esac
    
    unset choice
}

function __source_aws_functions() {
    local __AWS_SRE_TOOLS_SETUP_FILE="${__SRE_TOOLS_DIR}/aws/tools/setup.sh"
    local __AWS_CONNECT_FILE="${__SRE_TOOLS_DIR}/aws/defaults/aws_connect.sh"
    local __AWS_USERS_FILE="${__SRE_TOOLS_DIR}/aws/defaults/users/users.sh"
    local __AWS_HELP_FILE="${__SRE_TOOLS_DIR}/help.sh"
    
    if [ -f "${__AWS_SRE_TOOLS_SETUP_FILE}" ]; then 
        source "${__AWS_SRE_TOOLS_SETUP_FILE}" && __source_all_aws_functions
        echo -e "   ${GREEN}✓${NC} AWS functions"
    fi
    if [ -f "${__AWS_CONNECT_FILE}" ]; then 
        source "${__AWS_CONNECT_FILE}"
        echo -e "   ${GREEN}✓${NC} AWS connect functions"
    fi
    if [ -f "${__AWS_USERS_FILE}" ]; then 
        source "${__AWS_USERS_FILE}"
        echo -e "   ${GREEN}✓${NC} AWS users functions"
    fi
    if [ -f "${__AWS_HELP_FILE}" ]; then 
        source "${__AWS_HELP_FILE}"
        echo -e "   ${GREEN}✓${NC} AWS help"
    fi
    
    echo -e "${GREEN}AWS functions loaded.${NC}"
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
    
    echo -e "${GREEN}Mattermost functions loaded.${NC}"
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
    
    echo -e "${GREEN}Minikube functions loaded.${NC}"
}

function __source_go_functions() {
    local __GO_SETUP_FILE="${__GO_TOOLS_DIR}/setup.sh"
    local __GO_HELP_FILE="${__GO_TOOLS_DIR}/help.sh"
    
    if [ -f "${__GO_SETUP_FILE}" ]; then 
        source "${__GO_SETUP_FILE}"
        echo -e "   ${GREEN}✓${NC} Go tools setup"
    fi
    if [ -f "${__GO_HELP_FILE}" ]; then 
        source "${__GO_HELP_FILE}"
        echo -e "   ${GREEN}✓${NC} Go tools help"
    fi
    echo -e "${GREEN}Go tools functions loaded.${NC}"
}

function __source_python_functions(){ 
    [[ -f "${__PYTHON_TOOLS_DIR}" ]] && source "${__PYTHON_TOOLS_DIR}"/python-functions.sh
}

function __source_all_functions() {
    echo -e "${MAGENTA}Loading all SRE tools...${NC}"
    __source_aws_functions
    __source_minikube_functions
    __source_mattermost_functions
    __source_go_functions
    
    echo -e "${GREEN}All SRE tools setup completed.${NC}"
}

function reload_sre_tools(){
    source "${__SRE_TOOLS_DIR}/setup.sh"
}

# function update_sre_tools() {
#     echo -e "${CYAN}Updating SRE tools from dotfiles repository...${NC}"
#     echo -e ""
#     if [ -d "${__TOOLS_DIR}" ] && [ -d "$(dirname "${__TOOLS_DIR}")/.git" ]; then
#         pushd "$(dirname "${__TOOLS_DIR}")" > /dev/null
#         git pull
#         popd > /dev/null
#         echo -e "${GREEN}SRE tools updated successfully.${NC}"
#         echo -e "${YELLOW}Note: You may need to reload your shell or run ${GREEN}bashrc${NC} to apply changes.${NC}"
#     else
#         echo -e "${RED}Could not find git repository. Manual update required.${NC}"
#     fi
# }

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