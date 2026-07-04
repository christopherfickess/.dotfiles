#!/bin/bash

function myhelp_wsl() {
    echo -e "${__HEADER_COLOR__}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${__HEADER_COLOR__} WSL Commands${NC}"
    echo -e "${__HEADER_COLOR__}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if [[ "${SRE_TOOLS_VERBOSE:-false}" == "true" ]]; then
        __myhelp_wsl_advanced__
    else
        __myhelp_wsl_basic__
    fi

    echo ""
    if [[ "${SRE_TOOLS_VERBOSE:-false}" != "true" ]]; then
        echo -e "${__COMMAND_COLOR__}Tip:${NC} Set ${__DETAILS_COLOR__}SRE_TOOLS_VERBOSE=true${NC} or use ${__DETAILS_COLOR__}myhelp -v${NC} for all WSL commands"
    fi
    echo ""
    echo -e "For more information: ${__INFO_COLOR__}https://docs.microsoft.com/en-us/windows/wsl/reference${NC}"
}

function __myhelp_wsl_basic__() {
    echo -e "${BOLD}Custom WSL Functions:${NC}"
    echo -e "  ${__COMMAND_COLOR__}install_wsl${NC}                  Install WSL with Fedora"
    echo -e "  ${__COMMAND_COLOR__}destroy_wsl_distro${NC}           Uninstall WSL distribution"
    echo -e "  ${__COMMAND_COLOR__}update_wsl${NC}                   Update WSL kernel"
    echo ""
    echo -e "${BOLD}Built-in WSL Commands:${NC}"
    echo -e "  ${__COMMAND_COLOR__}wsl -l${NC}                       List installed distributions"
    echo -e "  ${__COMMAND_COLOR__}wsl --status${NC}                 Show WSL status"
    echo -e "  ${__COMMAND_COLOR__}wsl --shutdown${NC}               Shut down all WSL instances"
    echo -e "  ${__COMMAND_COLOR__}wsl --terminate <distro>${NC}     Stop specific distro"
    echo -e "  ${__COMMAND_COLOR__}wsl <command>${NC}                Run command in default distro"
    echo -e "  ${__COMMAND_COLOR__}wsl --update${NC}                 Update WSL components"
}

function __myhelp_wsl_advanced__() {
    __myhelp_wsl_basic__
    echo ""
    echo -e "${BOLD}Advanced Built-in Commands:${NC}"
    echo -e "  ${__COMMAND_COLOR__}wsl -l -v${NC}                    List distros with version/state"
    echo -e "  ${__COMMAND_COLOR__}wsl --install${NC}                Install WSL with default distro"
    echo -e "  ${__COMMAND_COLOR__}wsl --install <distro>${NC}       Install specific distro"
    echo -e "  ${__COMMAND_COLOR__}wsl --set-default <distro>${NC}   Set default distro"
    echo ""
    echo -e "${BOLD}Network & System:${NC}"
    echo -e "  ${__COMMAND_COLOR__}wsl hostname${NC}                 Get WSL hostname"
    echo -e "  ${__COMMAND_COLOR__}wsl ip addr${NC}                  Get IP/network info"
    echo -e "  ${__COMMAND_COLOR__}wsl cat /proc/version${NC}        Show kernel version"
    echo ""
    echo -e "${BOLD}Path Conversion:${NC}"
    echo -e "  ${__COMMAND_COLOR__}wslpath <WinPath>${NC}            Convert Windows to Linux path"
    echo -e "  ${__COMMAND_COLOR__}wslpath -w <LinuxPath>${NC}       Convert Linux to Windows path"
    echo ""
    echo -e "${BOLD}Update Management:${NC}"
    echo -e "  ${__COMMAND_COLOR__}wsl --update rollback${NC}        Roll back WSL kernel update"
}

# Legacy function name support
function _list_windows_wsl_commands() {
    if [[ "${SRE_TOOLS_VERBOSE:-false}" == "true" ]] || [[ "${__verbose__}" == "TRUE" ]]; then
        __myhelp_wsl_advanced__
    else
        __myhelp_wsl_basic__
    fi
}
