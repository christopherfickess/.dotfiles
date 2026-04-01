
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
    [[ -z "${__zellij_dir__}" ]] && __zellij_dir__="${__sre_tools_dir__}/zellij"

    # Handle command-line arguments first

    __sre_tools_menu_logic__ "$@"

    unset __aws_sre_tools_dir__
    unset __aws_connect_file__
    unset __aws_help_file__
    unset __mattermost_dir__
    unset __minikube_dir__
    unset __go_dir__
    unset __python_dir__
    unset __zellij_dir__
}


function source_folder_scripts() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo -e "${__COMMAND_COLOR__}Usage: source_folder_scripts <folder> [label]${NC}"
        return 1
    fi
    
    local folder="${1:?Usage: source_folder_scripts <folder> [label]}"
    local label="${2:-functions Installed}"
    local name
    for f in "${folder}"/*.sh; do
        [[ -f "$f" ]] || continue
        [[ "$(basename "$f")" == "setup.sh" ]] && continue
        . "$f"
        name="$(basename "$f" .sh)"
        echo -e "   ${GREEN}✓${NC} ${name} ${label}"
    done
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
            myhelp_sre_tools
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
        -z|--zellij)
            __source_zellij_functions__
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
    elif [[ "${1}" == "-z" || "${1}" == "--zellij" ]]; then
        __choice__="${1}"
    elif [[ ! -z "${1}" ]]; then
        # Interactive mode if no arguments provided
        echo -e "${CYAN}Which Functionality do you want to setup?${NC}"
        echo -e "   ${__COMMAND_COLOR__}-a${NC}    | --all           ${CYAN}All${NC}"
        echo -e "   ${__COMMAND_COLOR__}-aws${NC}  | --aws           ${CYAN}AWS Functions${NC}"
        echo -e "   ${__COMMAND_COLOR__}-g${NC}    | --go            ${CYAN}Go Tools${NC}"
        echo -e "   ${__COMMAND_COLOR__}-l${NC}    | --list          ${CYAN}List Available Tools${NC}"
        echo -e "   ${__COMMAND_COLOR__}-h${NC}    | --help          ${CYAN}Show Help${NC}"
        echo -e "   ${__COMMAND_COLOR__}-M${NC}    | --mattermost    ${CYAN}Mattermost${NC}"
        echo -e "   ${__COMMAND_COLOR__}-m${NC}    | --minikube      ${CYAN}Minikube${NC}"
        echo -e "   ${__COMMAND_COLOR__}-p${NC}    | --python        ${CYAN}Python Tools${NC}"
        echo -e "   ${__COMMAND_COLOR__}-u${NC}    | --update        ${CYAN}Update SRE Tools${NC}"
        echo -e "   ${__COMMAND_COLOR__}-v${NC}    | --version       ${CYAN}Show SRE Tools Version${NC}"
        echo -e "   ${__COMMAND_COLOR__}-z${NC}    | --zellij        ${CYAN}Zellij Templates${NC}"
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
    local __aws_help_file__="${__sre_tools_dir__}/aws/help.sh"

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

    # Register tool as loaded
    __SRE_TOOLS_LOADED__[aws]="true"

    unset __aws_sre_tools_setup_file__
    unset __aws_connect_file__
    unset __aws_users_file__
    unset __aws_help_file__
}

function __source_mattermost_functions__() {
    local __mattermost_setup__="${__mattermost_dir__}/setup.sh"
    local __mattermost_help__="${__mattermost_dir__}/help.sh"

    if [ -f "${__mattermost_setup__}" ]; then
        source "${__mattermost_setup__}"
        echo -e "   ${GREEN}✓${NC} Mattermost functions"
    fi
    if [ -f "${__mattermost_help__}" ]; then
        source "${__mattermost_help__}"
        echo -e "   ${GREEN}✓${NC} Mattermost help"
    fi

    echo -e "${MAGENTA}Mattermost functions loaded.${NC}"

    # Register tool as loaded
    __SRE_TOOLS_LOADED__[mattermost]="true"

    unset __mattermost_setup__
    unset __mattermost_help__
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

    # Register tool as loaded
    __SRE_TOOLS_LOADED__[minikube]="true"

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

    # Register tool as loaded
    __SRE_TOOLS_LOADED__[go]="true"

    unset __go_setup_file__
    unset __go_help_file__
}

function __source_python_functions__(){
    local __python_dir__="${__sre_tools_dir__}/python"
    local __python_functions_file__="${__python_dir__}/defaults/python-functions.sh"
    local __python_help_file__="${__python_dir__}/help.sh"

    if [ -f "${__python_functions_file__}" ]; then
        source "${__python_functions_file__}"
        echo -e "   ${GREEN}✓${NC} Python functions"
    fi
    if [ -f "${__python_help_file__}" ]; then
        source "${__python_help_file__}"
        echo -e "   ${GREEN}✓${NC} Python help"
    fi
    echo -e "${MAGENTA}Python functions loaded.${NC}"

    # Register tool as loaded
    __SRE_TOOLS_LOADED__[python]="true"

    unset __python_dir__
    unset __python_functions_file__
    unset __python_help_file__
}

function __source_zellij_functions__() {
    local __zellij_setup_file__="${__sre_tools_dir__}/zellij/setup.sh"
    local __zellij_help_file__="${__sre_tools_dir__}/zellij/defaults/help.sh"

    if [ -f "${__zellij_setup_file__}" ]; then
        source "${__zellij_setup_file__}"
        echo -e "   ${GREEN}✓${NC} Zellij functions"
    fi
    if [ -f "${__zellij_help_file__}" ]; then
        source "${__zellij_help_file__}"
        echo -e "   ${GREEN}✓${NC} Zellij help"
    fi

    echo -e "${MAGENTA}Zellij functions loaded.${NC}"

    # Register tool as loaded
    __SRE_TOOLS_LOADED__[zellij]="true"

    unset __zellij_setup_file__
    unset __zellij_help_file__
}

function __source_all_functions__() {
    __source_aws_functions__
    __source_minikube_functions__
    __source_mattermost_functions__
    __source_go_functions__
    __source_python_functions__
    __source_zellij_functions__

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
#         echo -e "${__COMMAND_COLOR__}Note: You may need to reload your shell or run ${GREEN}bashrc${NC} to apply changes.${NC}"
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
