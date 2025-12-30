
#!/bin/bash

# Initialize directory variables if not already set

function sre_tools() {    
    [[ -z "${__aws_sre_tools_dir__}" ]] && __aws_sre_tools_dir__="${__sre_tools_dir__}/aws"
    [[ -z "${__aws_connect_file__}" ]] && __aws_connect_file__="${__aws_sre_tools_dir__}/defaults/aws_connect.sh"
    [[ -z "${__aws_help_file__}" ]] && __aws_help_file__="${__aws_sre_tools_dir__}/help.sh"
    [[ -z "${__mattermost_dir__}" ]] && __mattermost_dir__="${__sre_tools_dir__}/mattermost"
    [[ -z "${__minikube_dir__}" ]] && __minikube_dir__="${__sre_tools_dir__}/minikube"
    [[ -z "${__go_dir__}" ]] && __go_dir__="${__sre_tools_dir__}/go"
    [[ -z "${__python_dir__}" ]] && __python_dir__="${__sre_tools_dir__}/python"

    # Handle command-line arguments first
    
    __sre_tools_menu_logic__ "$@"

    unset __aws_sre_tools_dir__
    unset __aws_connect_file__
    unset __aws_help_file__
    unset __mattermost_dir__
    unset __minikube_dir__
    unset __go_dir__
    unset __python_dir__
}

function __sre_tools_menu_logic__(){
    __list_sre_tools__ "$@"

    case $__choice__ in
        -a|--all)
            __source_all_functions__
            ;;
        -aws|--aws)
            __source_aws_functions__
            ;;
        -g|--go)
            __source_go_functions__
            ;;
        -h|--help)
            help_sre_tools
            ;;
        -l|--list)
            list_sre_tools
            ;;
        -M|--mattermost)
            __source_mattermost_functions__
            ;;
        -m|--minikube)
            __source_minikube_functions__
            ;;
        -p|--python)
            __source_python_functions__
            ;;
        -r|--reload)
            reload_sre_tools
            unset __choice__
            return 0
            ;;
        *)
            echo -e "${RED}Invalid choice.${NC}"
            unset __choice__
            return 1
            ;;
        
    esac
    
    unset __choice__
}

function __list_sre_tools__(){
    
    if [[ "${1}" == "-a" || "${1}" == "--all" ]]; then
        __choice__="${1}"
    elif [[ "${1}" == "-aws" || "${1}" == "--aws" ]]; then
        __choice__="${1}"
    elif [[ "${1}" == "-g" || "${1}" == "--go" ]]; then
        __choice__="${1}"
    elif [[ "${1}" == "-h" || "${1}" == "--help" ]]; then
        __choice__="${1}"
    elif [[ "${1}" == "-l" || "${1}" == "--list" ]]; then
        __choice__="${1}"
    elif [[ "${1}" == "-M" || "${1}" == "--mattermost" ]]; then
        __choice__="${1}"
    elif [[ "${1}" == "-m" || "${1}" == "--minikube" ]]; then
        __choice__="${1}"
    elif [[ "${1}" == "-p" || "${1}" == "--python" ]]; then
        __choice__="${1}"
    elif [[ "${1}" == "-u" || "${1}" == "--update" ]]; then
        __choice__="${1}"
    elif [[ "${1}" == "-v" || "${1}" == "--version" ]]; then
        __choice__="${1}"
    elif [[ ! -z "${1}" ]]; then
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

        read -p "   Enter your choice: " __choice__
    else
        echo -e "${RED}Invalid choice.${NC}"
        echo "here"
        return
    fi
    
}

function __source_aws_functions__() {
    local __aws_sre_tools_setup_file__="${__sre_tools_dir__}/aws/tools/setup.sh"
    local __aws_connect_file__="${__sre_tools_dir__}/aws/defaults/aws_connect.sh"
    local __aws_users_file__="${__sre_tools_dir__}/aws/defaults/users/users.sh"
    local __aws_help_file__="${__sre_tools_dir__}/help.sh"
    
    if [ -f "${__aws_sre_tools_setup_file__}" ]; then 
        source "${__aws_sre_tools_setup_file__}" && __source_all_aws_functions
        echo -e "   ${GREEN}✓${NC} AWS functions"
    fi
    if [ -f "${__aws_connect_file__}" ]; then 
        source "${__aws_connect_file__}"
        echo -e "   ${GREEN}✓${NC} AWS connect functions"
    fi
    if [ -f "${__aws_users_file__}" ]; then 
        source "${__aws_users_file__}"
        echo -e "   ${GREEN}✓${NC} AWS users functions"
    fi
    if [ -f "${__aws_help_file__}" ]; then 
        source "${__aws_help_file__}"
        echo -e "   ${GREEN}✓${NC} AWS help"
    fi
    
    echo -e "${MAGENTA}AWS functions loaded.${NC}"

    unset __aws_sre_tools_setup_file__
    unset __aws_connect_file__
    unset __aws_users_file__
    unset __aws_help_file__
}

function __source_mattermost_functions__() {
    local __mattermost_file__="${__mattermost_dir__}/mattermost.sh"
    local __mattermostfed_file__="${__mattermost_dir__}/mattermostfed.sh"
    local __mattermost_help_file__="${__mattermost_dir__}/help.sh"
    
    if [ -f "${__mattermost_file__}" ] && [[ "${MATTERMOST}" == "TRUE" ]]; then 
        source "${__mattermost_file__}"
        echo -e "   ${GREEN}✓${NC} Mattermost functions"
    fi
    if [ -f "${__mattermostfed_file__}" ] && [ "${MATTERMOSTFED}" == "TRUE" ]; then 
        source "${__mattermostfed_file__}"
        echo -e "   ${GREEN}✓${NC} Mattermost Fed functions"
    fi
    if [ -f "${__mattermost_help_file__}" ]; then 
        source "${__mattermost_help_file__}"
        echo -e "   ${GREEN}✓${NC} Mattermost help"
    fi
    
    echo -e "${MAGENTA}Mattermost functions loaded.${NC}"

    unset __mattermost_file__
    unset __mattermostfed_file__
    unset __mattermost_help_file__
}

function __source_minikube_functions__() {
    local __minikube_functions_file__="${__minikube_dir__}/minikube_functions.sh"
    local __minikube_setup_file__="${__minikube_dir__}/setup_minikube.sh"
    local __minikube_help_file__="${__minikube_dir__}/help.sh"
    
    if [ -f "${__minikube_functions_file__}" ]; then 
        source "${__minikube_functions_file__}"
        echo -e "   ${GREEN}✓${NC} Minikube functions"
    fi
    if [ -f "${__minikube_setup_file__}" ]; then 
        source "${__minikube_setup_file__}"
        echo -e "   ${GREEN}✓${NC} Minikube setup"
    fi
    if [ -f "${__minikube_help_file__}" ]; then 
        source "${__minikube_help_file__}"
        echo -e "   ${GREEN}✓${NC} Minikube help"
    fi
    
    echo -e "${MAGENTA}Minikube functions loaded.${NC}"

    unset __minikube_functions_file__
    unset __minikube_setup_file__
    unset __minikube_help_file__
}

function __source_go_functions__() {
    local __go_setup_file__="${__go_dir__}/setup.sh"
    local __go_help_file__="${__go_dir__}/help.sh"
    
    if [ -f "${__go_setup_file__}" ]; then 
        source "${__go_setup_file__}"
        echo -e "   ${GREEN}✓${NC} Go tools setup"
    fi
    if [ -f "${__go_help_file__}" ]; then 
        source "${__go_help_file__}"
        echo -e "   ${GREEN}✓${NC} Go tools help"
    fi
    echo -e "${MAGENTA}Go tools functions loaded.${NC}"

    unset __go_setup_file__
    unset __go_help_file__
}

function __source_python_functions__(){ 
    local __python_dir__="${__sre_tools_dir__}/python"
    local __python_functions_file__="${__python_dir__}/defaults/python-functions.sh"
    
    if [ -f "${__python_functions_file__}" ]; then 
        source "${__python_functions_file__}"
        echo -e "   ${GREEN}✓${NC} Python functions"
    fi
    echo -e "${MAGENTA}Python functions loaded.${NC}"
    unset __python_dir__
    unset __python_functions_file__
}

function __source_all_functions__() {
    __source_aws_functions__
    __source_minikube_functions__
    __source_mattermost_functions__
    __source_go_functions__
    __source_python_functions__
    
    echo -e "${GREEN}All SRE tools setup completed.${NC}"
}

# function update_sre_tools() {
#     echo -e "${CYAN}Updating SRE tools from dotfiles repository...${NC}"
#     echo -e ""
#     if [ -d "${__tools_dir__}" ] && [ -d "$(dirname "${__tools_dir__}")/.git" ]; then
#         pushd "$(dirname "${__tools_dir__}")" > /dev/null
#         git pull
#         popd > /dev/null
#         echo -e "${GREEN}SRE tools updated successfully.${NC}"
#         echo -e "${YELLOW}Note: You may need to reload your shell or run ${GREEN}bashrc${NC} to apply changes.${NC}"
#     else
#         echo -e "${RED}Could not find git repository. Manual update required.${NC}"
#     fi
# }

function show_sre_tools_version() {
    local __version_file__="${__tools_dir__}/VERSION"
    if [ -f "${__version_file__}" ]; then
        echo -e "${CYAN}SRE Tools Version:${NC} $(cat "${__version_file__}")"
    else
        echo -e "${CYAN}SRE Tools Version:${NC} Unknown (no VERSION file found)"
    fi
    echo -e "${CYAN}Dotfiles Location:${NC} ${__tools_dir__}"
}
