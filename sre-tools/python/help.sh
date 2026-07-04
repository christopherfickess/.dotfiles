#!/bin/bash

function myhelp_python(){
    echo -e "${__HEADER_COLOR__}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${__HEADER_COLOR__} Python Tools${NC}"
    echo -e "${__HEADER_COLOR__}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if [[ "${SRE_TOOLS_VERBOSE:-false}" == "true" ]]; then
        __myhelp_python_advanced__
    else
        __myhelp_python_basic__
    fi

    echo ""
    if [[ "${SRE_TOOLS_VERBOSE:-false}" != "true" ]]; then
        echo -e "${__COMMAND_COLOR__}Tip:${NC} Set ${__DETAILS_COLOR__}SRE_TOOLS_VERBOSE=true${NC} or use ${__DETAILS_COLOR__}myhelp -v${NC} for advanced commands"
    fi
}

function __myhelp_python_basic__() {
    echo -e "${BOLD}Common Commands:${NC}"
    echo -e "  ${__COMMAND_COLOR__}disable_python_env${NC} <name>    Deactivate Python ENV"
    echo -e "  ${__COMMAND_COLOR__}setup_python_env${NC} <name>      Activate Python ENV"
}

function __myhelp_python_advanced__() {
    __myhelp_python_basic__
    echo ""
    echo -e "${BOLD}Advanced Commands:${NC}"
    echo -e "  ${__COMMAND_COLOR__}python_env_info${NC} <name>       Tells information about Python ENV"
}
