#!/bin/bash


function help_wsl() {
    echo -e ""
    echo -e "Description:"
    echo -e "------------------------------------------------------------------------------------------------------"
    echo -e "${MAGENTA}This function provides a list of useful WSL (Windows Subsystem for Linux) commands to help users "
    echo -e "   navigate and manage their WSL environments effectively.${NC}"
    echo -e ""
    echo -e "WSL Commands:"
    echo -e "------------------------------------------------------------------------------------------------------"
    echo -e ""
    _list_windows_wsl_commands

    echo -e ""
    echo -e "${MAGENTA}For more information, visit: https://docs.microsoft.com/en-us/windows/wsl/reference${NC}"
}


# ------------------
# Secret Functions
# ------------------
function _list_windows_wsl_commands(){
    echo -e "   ${YELLOW}wsl -l${NC}                        - List installed Linux distributions"
    echo -e "   ${YELLOW}wsl -l -v${NC}                     - List installed distros with version/state"
    echo -e ""
    echo -e "   ${YELLOW}wsl --install${NC}                 - Install WSL with default distro"
    echo -e "   ${YELLOW}wsl --install <distro>${NC}        - Install a specific distro"
    echo -e "   ${YELLOW}wsl --set-default <distro>${NC}    - Set default distro"
    echo -e ""
    echo -e "   ${YELLOW}wsl --status${NC}                  - Show WSL status + default distro"
    echo -e "   ${YELLOW}wsl --shutdown${NC}                - Shut down all WSL instances"
    echo -e "   ${YELLOW}wsl --terminate <distro>${NC}      - Stop a specific distro"
    echo -e ""
    echo -e "   ${YELLOW}wsl <command>${NC}                 - Run command in default distro"
    echo -e "   ${YELLOW}wsl -d <distro> <command>${NC}     - Run command in specific distro"
    echo -e "   ${YELLOW}wsl -u <user> <command>${NC}       - Run as specific user"
    echo -e "   ${YELLOW}wsl --exec <command>${NC}          - Execute command without a shell"
    echo -e ""
    echo -e "   ${YELLOW}wsl hostname${NC}                  - Get hostname inside WSL"
    echo -e "   ${YELLOW}wsl ip addr${NC}                   - Get IP/network info"
    echo -e "   ${YELLOW}wsl cat /proc/version${NC}         - Show kernel version"
    echo -e ""
    echo -e "   ${YELLOW}wslpath <WinPath>${NC}             - Convert Windows path to Linux path"
    echo -e "   ${YELLOW}wslpath -w <LinuxPath>${NC}        - Convert Linux path to Windows path"
    echo -e ""
    echo -e "   ${YELLOW}wsl --update${NC}                  - Update WSL kernel and components"
    echo -e "   ${YELLOW}wsl --update rollback${NC}         - Roll back last WSL kernel update"
}
