#!/bin/bash

function zell(){
    # case statement to handle different zellij layouts based on user input
    if [ -z "$1" ]; then
        __zell_menu__
    else
        __choice_zell__="$1"
        __zell_logic__ "$@"
    fi
}

function __zell_logic__(){
    case "$__choice_zell__" in
        -9|--k9s)
            local __type__="k9s"
            local __template__="${__sre_tools_dir__}/zellij/templates/k9s-only.kdl"
            __zellij_run_template__
            ;;
        -c|--create)
            __create_zellij_template__
            ;;
        -f|--flux)
            local __type__="flux"
            local __template__="${__sre_tools_dir__}/zellij/templates/flux-watch.kdl"   
            __zellij_run_template__
            ;;
        -h|--help)
            __zell_menu__
            ;;
        -l|--list)
            __list_zellij_templates__
            ;;
        -k|--kubectl)
            local __type__="kubectl-checks"
            local __template__="${__sre_tools_dir__}/zellij/templates/kubectl-checks.kdl"   
            __zellij_namespace_watch__ "$2" "${__template__}" "${__type__}"
            ;;
        -m|--mattermost)
            local __type__="mattermost-watch"
            local __template__="${__sre_tools_dir__}/zellij/templates/mattermost.kdl"
            __zellij_run_template__
            ;;
        -n|--namespaces)
            local __type__="namespace-watch"
            local __template__="${__sre_tools_dir__}/zellij/templates/namespace-filtered-watch.kdl"
            __zellij_namespace_watch__ "$2" "${__template__}" "${__type__}"
            ;;
        *)
            __zell_menu__
            ;;
    esac
}

function __zell_menu__(){
    __color_help__

    echo -e "${CYAN}Zell - Zellij Layout Launcher${NC}"
    echo -e "Usage: zell <flags>"
    echo -e "Available layouts:"
    echo -e "   ${__COMMAND_COLOR__}-9|--k9s${NC} - Watch K9s deployments with a custom Zellij layout"
    echo -e "   ${__COMMAND_COLOR__}-c|--create${NC} - Create a new Zellij template with a basic layout"
    echo -e "   ${__COMMAND_COLOR__}-f|--flux${NC} - Watch Flux deployments with a custom Zellij layout"
    echo -e "   ${__COMMAND_COLOR__}-h|--help${NC} - Show this help menu"
    echo -e "   ${__COMMAND_COLOR__}-l|--list${NC} - List available Zellij templates"
    echo -e "   ${__COMMAND_COLOR__}-k|--kubectl${NC} - Run kubectl checks in a Zellij layout"
    echo -e "   ${__COMMAND_COLOR__}-m|--mattermost${NC} - Custom Zellij layout for watching Mattermost deployments"
    echo -e "   ${__COMMAND_COLOR__}-n|--namespaces${NC} - Watch namespaces with pattern filtering in Zellij"
}


function __zellij_run_template__() {
    # Launch zellij with k9s deployment watch template
    if [ -n "$__template__" ] && [ -n "${__type__}" ]; then
        echo -e "${YELLOW}Custom template provided: ${__template__}${NC}"
        echo -e "${GREEN}Starting Zellij with custom template: ${__type__}...${NC}"
        zellij --layout "${__template__}"
    else
        echo -e "${RED}Template not found: ${__template__}${NC}"
        return
    fi
    return
}
function __zellij_namespace_watch__() {
    local __pattern__="${1}"
    local __template__="${2}"
    local __type__="${3}"

    if [ -z "${__pattern__}" ]; then
        echo -e "${YELLOW}Enter the namespace pattern to watch (e.g., 'mattermost'): ${NC}"
        read -p "   :>  " __pattern__
        __pattern__="${__pattern__:-mattermost}"
    fi

    if [ -n "${__template__}" ] && [ -n "${__type__}" ]; then
        echo -e "${YELLOW}Custom template provided: ${__template__}${NC}"
        echo -e "${GREEN}Starting Zellij with custom template: ${__type__}...${NC}"

        local __tmp__
        __tmp__=$(mktemp /tmp/zellij-layout-XXXXXX.kdl)
        NAMESPACE_PATTERN="${__pattern__}" envsubst < "${__template__}" > "${__tmp__}"
        zellij --layout "${__tmp__}"
        rm -f "${__tmp__}"
    else
        echo -e "${RED}Template not found: ${__template__}${NC}"
        return 1
    fi
}

# function __zellij_namespace_watch__() {
#     # Launch zellij with namespace pattern filtering
    
#     if [ -z "${1}" ]; then
#         echo -e "${YELLOW}Enter the namespace pattern to watch (e.g., 'mattermost'): ${NC}"
#         read -p "   :>  " __pattern__
#         __pattern__="${__pattern__:-mattermost}"
#     else
#         __pattern__="${1}"
#     fi

#     if [ -n "$__template__" ] && [ -n "${__type__}" ]; then
#         echo -e "${YELLOW}Custom template provided: ${__template__}${NC}"
#         echo -e "${GREEN}Starting Zellij with custom template: ${__type__}...${NC}"
#         envsubst < "${__template__}" | zellij --layout /dev/stdin
#     else
#         echo -e "${RED}Template not found: ${__template__}${NC}"
#         return
#     fi
#     return
# }

function __list_zellij_templates__() {
    echo -e "${CYAN}Available Zellij Templates:${NC}"
    echo -e "------------------------------------------------------------------------------------------------------"

    local __templates_dir__="${__sre_tools_dir__}/zellij/templates"

    if [ -d "${__templates_dir__}" ]; then
        for __template__ in "${__templates_dir__}"/*.kdl; do
            if [ -f "${__template__}" ]; then
                echo -e "   ${YELLOW}$(basename ${__template__})${NC}"
            fi
        done
    fi

    # Also show custom templates in main zellij directory
    echo -e "\n${CYAN}Custom Templates:${NC}"
    for __template__ in "${__sre_tools_dir__}/zellij/templates/custom"/*.kdl; do
        if [ -f "${__template__}" ]; then
            echo -e "   ${YELLOW}$(basename ${__template__})${NC}"
        fi
    done
}
