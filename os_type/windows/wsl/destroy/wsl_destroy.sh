
function destroy_wsl_distro() {
    if [ ! -z "$1" ]; then
        __distro_name__="$1"
    else
        __distro_name__="FedoraLinux-43" 
    fi

    echo -e "${YELLOW}Preparing to unregister (delete) WSL distribution: $__distro_name__${NC}"
    echo -e "${YELLOW}This action is irreversible and will delete all data associated with this distribution.${NC}"
    echo -e "${YELLOW}Press Ctrl+C to cancel or wait 5 seconds to continue...${NC}"
    sleep 5
    echo 
    echo -e "${MAGENTA}Unregistering (deleting) WSL distribution: $__distro_name__${NC}"
    echo
    wsl.exe -t "$__distro_name__"
    wsl.exe --unregister "$__distro_name__"
    echo
    echo -e "${GREEN}Distribution $__distro_name__ has been unregistered.${NC}"
}