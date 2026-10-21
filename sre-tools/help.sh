#!/bin/bash

# Global registry to track loaded tools
declare -gA __SRE_TOOLS_LOADED__ 2>/dev/null || true

# Main unified help (sre_tools -h)
function myhelp_sre_tools() {
    __color_help__
    echo -e "${__HEADER_COLOR__}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${__HEADER_COLOR__} SRE Tools - Unified Help System${NC}"
    echo -e "${__HEADER_COLOR__}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    __myhelp_sre_tools_commands__

    echo ""

    local loaded_count=0
    local loaded_tools=()
    local tool

    for tool in ai aws azure docker flux go kubernetes mattermost minikube python zellij; do
        if [[ "${__SRE_TOOLS_LOADED__[$tool]}" == "true" ]]; then
            loaded_tools+=("${tool}")
            ((loaded_count++)) || true
        fi
    done

    if [[ "${loaded_count}" -gt 0 ]]; then
        echo -e "${__HEADER_COLOR__}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${__HEADER_COLOR__} Loaded Tools (${loaded_count})${NC}"
        echo -e "${__HEADER_COLOR__}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""

        for tool in "${loaded_tools[@]}"; do
            case "${tool}" in
                ai)
                    printf "  %-30s %s\n" "${__DETAILS_COLOR__}AI skills/agents${NC}" "${__COMMAND_COLOR__}setup_ai_tools${NC}"
                    ;;
                aws)
                    printf "  %-30s %s\n" "${__DETAILS_COLOR__}AWS Functions${NC}" "${__COMMAND_COLOR__}myhelp_aws${NC}"
                    ;;
                azure)
                    printf "  %-30s %s\n" "${__DETAILS_COLOR__}Azure Functions${NC}" "${__COMMAND_COLOR__}myhelp_azure${NC}"
                    ;;
                docker)
                    printf "  %-30s %s\n" "${__DETAILS_COLOR__}Docker Functions${NC}" "${__COMMAND_COLOR__}myhelp_docker${NC}"
                    ;;
                flux)
                    printf "  %-30s %s\n" "${__DETAILS_COLOR__}Flux Functions${NC}" "${__COMMAND_COLOR__}myhelp_flux${NC}"
                    ;;
                go)
                    printf "  %-30s %s\n" "${__DETAILS_COLOR__}Go Tools${NC}" "${__COMMAND_COLOR__}myhelp_go${NC}"
                    ;;
                kubernetes)
                    printf "  %-30s %s\n" "${__DETAILS_COLOR__}Kubernetes Functions${NC}" "${__COMMAND_COLOR__}myhelp_kubernetes${NC}"
                    ;;
                mattermost)
                    printf "  %-30s %s\n" "${__DETAILS_COLOR__}Mattermost Tools${NC}" "${__COMMAND_COLOR__}myhelp_mattermost${NC}"
                    ;;
                minikube)
                    printf "  %-30s %s\n" "${__DETAILS_COLOR__}Minikube Functions${NC}" "${__COMMAND_COLOR__}myhelp_minikube${NC}"
                    ;;
                python)
                    printf "  %-30s %s\n" "${__DETAILS_COLOR__}Python Tools${NC}" "${__COMMAND_COLOR__}myhelp_python${NC}"
                    ;;
                zellij)
                    printf "  %-30s %s\n" "${__DETAILS_COLOR__}Zellij Layouts${NC}" "${__COMMAND_COLOR__}myhelp_zellij${NC}"
                    ;;
                *)
                    printf "  %-30s %s\n" "${__DETAILS_COLOR__}${tool}${NC}" "${__COMMAND_COLOR__}(loaded)${NC}"
                    ;;
            esac
        done

        echo ""
        echo -e "${__COMMAND_COLOR__}Tip:${NC} Run ${__DETAILS_COLOR__}'myhelp_<tool>'${NC} for detailed help on a specific tool"

        if [[ "${SRE_TOOLS_VERBOSE:-false}" != "true" ]]; then
            echo -e "${__COMMAND_COLOR__}Tip:${NC} Set ${__DETAILS_COLOR__}SRE_TOOLS_VERBOSE=true${NC} for advanced commands"
        fi
    else
        echo -e "${__COMMAND_COLOR__}No tools currently loaded.${NC}"
        echo -e "Use ${__DETAILS_COLOR__}sre_tools -a${NC} to load all tools, or ${__DETAILS_COLOR__}sre_tools -<tool>${NC} for specific tools"
    fi

    echo ""
}

function __myhelp_sre_tools_commands__() {
    echo -e "${BOLD}Main Commands:${NC}"
    echo -e "  ${__COMMAND_COLOR__}sre_tools -a${NC}, ${__COMMAND_COLOR__}--all${NC}           Load all SRE tools (includes AI)"
    echo -e "  ${__COMMAND_COLOR__}sre_tools -A${NC}, ${__COMMAND_COLOR__}--ai${NC}            Link AI skills/agents (Cursor, Claude, OpenCode)"
    echo -e "  ${__COMMAND_COLOR__}sre_tools -aws${NC}, ${__COMMAND_COLOR__}--aws${NC}         Load AWS functions"
    echo -e "  ${__COMMAND_COLOR__}sre_tools -f${NC}, ${__COMMAND_COLOR__}--flux${NC}          Load Flux functions"
    echo -e "  ${__COMMAND_COLOR__}sre_tools -g${NC}, ${__COMMAND_COLOR__}--go${NC}            Load Go tools"
    echo -e "  ${__COMMAND_COLOR__}sre_tools -h${NC}, ${__COMMAND_COLOR__}--help${NC}          Show this help"
    echo -e "  ${__COMMAND_COLOR__}sre_tools -l${NC}, ${__COMMAND_COLOR__}--list${NC}          List available tools"
    echo -e "  ${__COMMAND_COLOR__}sre_tools -M${NC}, ${__COMMAND_COLOR__}--mattermost${NC}    Load Mattermost functions"
    echo -e "  ${__COMMAND_COLOR__}sre_tools -m${NC}, ${__COMMAND_COLOR__}--minikube${NC}      Load Minikube functions"
    echo -e "  ${__COMMAND_COLOR__}sre_tools -p${NC}, ${__COMMAND_COLOR__}--python${NC}        Load Python tools"
    echo -e "  ${__COMMAND_COLOR__}sre_tools -r${NC}, ${__COMMAND_COLOR__}--reload${NC}        Reload sre_tools from disk"
    echo -e "  ${__COMMAND_COLOR__}sre_tools -u${NC}, ${__COMMAND_COLOR__}--update${NC}        git pull ~/.dotfiles"
    echo -e "  ${__COMMAND_COLOR__}sre_tools -v${NC}, ${__COMMAND_COLOR__}--version${NC}       Show SRE tools version / path"
    echo -e "  ${__COMMAND_COLOR__}sre_tools -z${NC}, ${__COMMAND_COLOR__}--zellij${NC}        Load Zellij layouts"
    echo ""
    echo -e "${BOLD}AI shortcut (no sre_tools):${NC}"
    echo -e "  ${__COMMAND_COLOR__}source ~/.dotfiles/ai/setup.sh && setup_ai_tools${NC}"
}

function __myhelp_sre_tools_list__() {
    echo -e "${__HEADER_COLOR__}Available SRE Tools:${NC}"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "  ${__COMMAND_COLOR__}AI${NC}           - Cursor/Claude/OpenCode skills & agents (${__DETAILS_COLOR__}sre_tools -A${NC})"
    echo -e "  ${__COMMAND_COLOR__}AWS${NC}          - AWS SRE functions and utilities (${__DETAILS_COLOR__}sre_tools -aws${NC})"
    echo -e "  ${__COMMAND_COLOR__}Flux${NC}         - Flux CD helpers (${__DETAILS_COLOR__}sre_tools -f${NC})"
    echo -e "  ${__COMMAND_COLOR__}Go${NC}           - Go development tools (${__DETAILS_COLOR__}sre_tools -g${NC})"
    echo -e "  ${__COMMAND_COLOR__}Mattermost${NC}   - Mattermost development and deployment (${__DETAILS_COLOR__}sre_tools -M${NC})"
    echo -e "  ${__COMMAND_COLOR__}Minikube${NC}     - Local Kubernetes development (${__DETAILS_COLOR__}sre_tools -m${NC})"
    echo -e "  ${__COMMAND_COLOR__}Python${NC}       - Python development tools (${__DETAILS_COLOR__}sre_tools -p${NC})"
    echo -e "  ${__COMMAND_COLOR__}Zellij${NC}       - Terminal workspace layouts (${__DETAILS_COLOR__}sre_tools -z${NC})"
    echo ""
    echo -e "Load everything: ${__DETAILS_COLOR__}sre_tools -a${NC}"
    echo -e "After ${__DETAILS_COLOR__}git pull${NC} in ~/.dotfiles, run ${__DETAILS_COLOR__}sre_tools -r${NC} (or open a new shell) so new flags load."
}

# Legacy support - redirect old function
function list_sre_tools() {
    __myhelp_sre_tools_list__
}
