#!/bin/bash

# Global registry to track loaded tools
declare -gA __SRE_TOOLS_LOADED__ 2>/dev/null || true

# Main unified help function
function myhelp_sre_tools() {
    __color_help__
    echo -e "${__HEADER_COLOR__}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${__HEADER_COLOR__} SRE Tools - Unified Help System${NC}"
    echo -e "${__HEADER_COLOR__}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # Show main SRE tools help
    myhelp_sre_tools

    echo ""

    # Auto-discover and show loaded tools
    local loaded_count=0
    local loaded_tools=()

    # Check which tools are loaded
    for tool in aws azure docker go kubernetes mattermost minikube python zellij; do
        if [[ "${__SRE_TOOLS_LOADED__[$tool]}" == "true" ]]; then
            loaded_tools+=("$tool")
            ((loaded_count++))
        fi
    done

    # Show loaded tools section if any are loaded
    if [[ $loaded_count -gt 0 ]]; then
        echo -e "${__HEADER_COLOR__}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${__HEADER_COLOR__} Loaded Tools (${loaded_count})${NC}"
        echo -e "${__HEADER_COLOR__}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""

        # Display each loaded tool with its help command
        for tool in "${loaded_tools[@]}"; do
            case "$tool" in
                aws)
                    printf "  %-30s %s\n" "${__DETAILS_COLOR__}AWS Functions${NC}" "${__COMMAND_COLOR__}myhelp_aws${NC}"
                    ;;
                azure)
                    printf "  %-30s %s\n" "${__DETAILS_COLOR__}Azure Functions${NC}" "${__COMMAND_COLOR__}myhelp_azure${NC}"
                    ;;
                docker)
                    printf "  %-30s %s\n" "${__DETAILS_COLOR__}Docker Functions${NC}" "${__COMMAND_COLOR__}myhelp_docker${NC}"
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

function myhelp_sre_tools() {
    echo -e "${BOLD}Main Commands:${NC}"
    echo -e "  ${__COMMAND_COLOR__}sre_tools -a${NC}, ${__COMMAND_COLOR__}--all${NC}         Load all SRE tools"
    echo -e "  ${__COMMAND_COLOR__}sre_tools -aws${NC}, ${__COMMAND_COLOR__}--aws${NC}       Load AWS functions"
    echo -e "  ${__COMMAND_COLOR__}sre_tools -z${NC}, ${__COMMAND_COLOR__}--zellij${NC}      Load Zellij functions"
    echo -e "  ${__COMMAND_COLOR__}sre_tools -M${NC}, ${__COMMAND_COLOR__}--mattermost${NC}  Load Mattermost functions"
    echo -e "  ${__COMMAND_COLOR__}sre_tools -m${NC}, ${__COMMAND_COLOR__}--minikube${NC}    Load Minikube functions"
    echo -e "  ${__COMMAND_COLOR__}sre_tools -h${NC}, ${__COMMAND_COLOR__}--help${NC}        Show this help"
    echo -e "  ${__COMMAND_COLOR__}sre_tools -l${NC}, ${__COMMAND_COLOR__}--list${NC}        List available tools"
}

function __myhelp_sre_tools_list__() {
    echo -e "${__HEADER_COLOR__}Available SRE Tools:${NC}"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "  ${__COMMAND_COLOR__}AWS${NC}          - AWS SRE functions and utilities"
    echo -e "  ${__COMMAND_COLOR__}Azure${NC}        - Azure cloud functions"
    echo -e "  ${__COMMAND_COLOR__}Docker${NC}       - Docker container management"
    echo -e "  ${__COMMAND_COLOR__}Go${NC}           - Go development tools"
    echo -e "  ${__COMMAND_COLOR__}Kubernetes${NC}   - Kubernetes cluster management"
    echo -e "  ${__COMMAND_COLOR__}Mattermost${NC}   - Mattermost development and deployment"
    echo -e "  ${__COMMAND_COLOR__}Minikube${NC}     - Local Kubernetes development"
    echo -e "  ${__COMMAND_COLOR__}Python${NC}       - Python development tools"
    echo -e "  ${__COMMAND_COLOR__}Zellij${NC}       - Terminal workspace layouts"
    echo ""
    echo -e "To load a specific tool, use the corresponding option:"
    echo ""
    echo -e "  ${__DETAILS_COLOR__}sre_tools -aws${NC}      Load AWS functions"
    echo -e "  ${__DETAILS_COLOR__}sre_tools -z${NC}        Load Zellij functions"
    echo -e "  ${__DETAILS_COLOR__}sre_tools -M${NC}        Load Mattermost functions"
}

# Legacy support - redirect old function
function list_sre_tools() {
    __myhelp_sre_tools_list__
}
