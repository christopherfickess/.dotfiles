#!/bin/bash


function help_wsl() {
    echo -e "${GREEN}WSL Commands:${NC}"
    _list_windows_wsl_commands

    echo -e ""
    echo -e "${YELLOW}For more information, visit: https://docs.microsoft.com/en-us/windows/wsl/reference${NC}"
}


# ------------------
# Secret Functions
# ------------------
function _list_windows_wsl_commands(){
    echo -e "wsl -l                                     ${GREEN}# List installed Linux distributions${NC}"
    echo -e "wsl -l -v                                  ${GREEN}# List installed distros with version/state${NC}"
    echo -e ""
    echo -e "wsl --install                              ${GREEN}# Install WSL with default distro${NC}"
    echo -e "wsl --install <distro>                     ${GREEN}# Install a specific distro${NC}"
    echo -e "wsl --set-default <distro>                 ${GREEN}# Set default distro${NC}"
    echo -e ""
    echo -e "wsl --status                ${GREEN}# Show WSL status + default distro${NC}"
    echo -e "wsl --shutdown              ${GREEN}# Shut down all WSL instances${NC}"
    echo -e "wsl --terminate <distro>    ${GREEN}# Stop a specific distro${NC}"
    echo -e ""
    echo -e "wsl <command>               ${GREEN}# Run command in default distro${NC}"
    echo -e "wsl -d <distro> <command>   ${GREEN}# Run command in specific distro${NC}"
    echo -e "wsl -u <user> <command>     ${GREEN}# Run as specific user${NC}"
    echo -e "wsl --exec <command>        ${GREEN}# Execute command without a shell${NC}"
    echo -e ""
    echo -e "wsl hostname                ${GREEN}# Get hostname inside WSL${NC}"
    echo -e "wsl ip addr                 ${GREEN}# Get IP/network info${NC}"
    echo -e "wsl cat /proc/version       ${GREEN}# Show kernel version${NC}"
    echo -e ""
    echo -e "wslpath <WinPath>           ${GREEN}# Convert Windows path to Linux path${NC}"
    echo -e "wslpath -w <LinuxPath>      ${GREEN}# Convert Linux path to Windows path${NC}"
    echo -e ""
    echo -e "wsl --update                ${GREEN}# Update WSL kernel and components${NC}"
    echo -e "wsl --update rollback       ${GREEN}# Roll back last WSL kernel update${NC}"
}
