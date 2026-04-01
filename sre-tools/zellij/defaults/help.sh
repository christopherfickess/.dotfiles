#!/bin/bash

function myhelp_zellij() {
    echo -e "${__HEADER_COLOR__}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${__HEADER_COLOR__} Zellij Layouts - Help${NC}"
    echo -e "${__HEADER_COLOR__}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${BOLD}Common Commands:${NC}"
    echo -e "  ${__COMMAND_COLOR__}zellij_k9s_watch${NC}            Launch K9s deployment watch"
    echo -e "  ${__COMMAND_COLOR__}zellij_flux_watch${NC}           Launch Flux monitoring layout"
    echo -e "  ${__COMMAND_COLOR__}zellij_mattermost_watch${NC}     Launch Mattermost monitoring"
    echo -e "  ${__COMMAND_COLOR__}zellij_kubectl_checks${NC}       Launch kubectl health checks"
    echo -e "  ${__COMMAND_COLOR__}list_zellij_templates${NC}       List available templates"

    if [[ "${SRE_TOOLS_VERBOSE:-false}" == "true" ]]; then
        echo ""
        echo -e "${BOLD}Advanced Commands:${NC}"
        echo -e "  ${__COMMAND_COLOR__}zellij_namespace_watch${NC}      Watch specific namespace pattern"
        echo -e "  ${__COMMAND_COLOR__}create_zellij_template${NC}      Create new template"
    fi


    if [[ "${SRE_TOOLS_VERBOSE:-false}" != "true" ]]; then
        echo -e "${__COMMAND_COLOR__}Tip:${NC} Set ${__DETAILS_COLOR__}SRE_TOOLS_VERBOSE=true${NC} for advanced commands"
    fi

    echo ""
    echo -e "For more information: ${__INFO_COLOR__}https://zellij.dev/documentation/${NC}"
}
