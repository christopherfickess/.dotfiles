#!/bin/bash

function myhelp_mattermost() {
    echo -e "${__HEADER_COLOR__}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${__HEADER_COLOR__} Mattermost Functions${NC}"
    echo -e "${__HEADER_COLOR__}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if [[ "${SRE_TOOLS_VERBOSE:-false}" == "true" ]]; then
        __myhelp_mattermost_advanced__
    else
        __myhelp_mattermost_basic__
    fi

    echo ""
    if [[ "${SRE_TOOLS_VERBOSE:-false}" != "true" ]]; then
        echo -e "${__COMMAND_COLOR__}Tip:${NC} Set ${__DETAILS_COLOR__}SRE_TOOLS_VERBOSE=true${NC} or use ${__DETAILS_COLOR__}myhelp -v${NC} for advanced Mattermost commands"
    fi
}

function __myhelp_mattermost_basic__() {
    echo -e "${BOLD}Common Commands:${NC}"
    echo -e "  ${__COMMAND_COLOR__}mmctl${NC}                        Mattermost command line tool"
    echo -e "  ${__COMMAND_COLOR__}mmmutils${NC}                     Check if mm-utils is installed"
    echo -e "  ${__COMMAND_COLOR__}update_mattermost_ctl${NC}        Update the Mattermost ctl Tool to the latest version"
}

function __myhelp_mattermost_advanced__() {
    __myhelp_mattermost_basic__
    echo ""
    echo -e "${BOLD}Advanced Mattermost Functions:${NC}"
    echo -e "  ${__COMMAND_COLOR__}clone_mattermost_repo${NC}        Clone all Mattermost repositories"
    echo -e "  ${__COMMAND_COLOR__}mattermost_build${NC}             Build server/webapp (server|webapp|all)"
    echo -e "  ${__COMMAND_COLOR__}mattermost_cleanup${NC}           Clean up development environment"
    echo -e "  ${__COMMAND_COLOR__}mattermost_cloud_deploy${NC}      Deploy to Mattermost Cloud"
    echo -e "  ${__COMMAND_COLOR__}mattermost_config_check${NC}      Check configuration and setup"
    echo -e "  ${__COMMAND_COLOR__}mattermost_db_reset${NC}          Reset Mattermost database (destructive)"
    echo -e "  ${__COMMAND_COLOR__}mattermost_docker_compose${NC}    Manage docker-compose services (up/down/logs/ps)"
    echo -e "  ${__COMMAND_COLOR__}mattermost_logs_tail${NC}         Tail logs for a service"
    echo -e "  ${__COMMAND_COLOR__}mattermost_operator_deploy${NC}   Deploy Mattermost Operator to Kubernetes"
    echo -e "  ${__COMMAND_COLOR__}mattermost_rollout${NC}           Rollout a new version of Mattermost in Kubernetes"
    echo -e "  ${__COMMAND_COLOR__}mattermost_test${NC}              Run tests (unit|integration|e2e|all)"
}
