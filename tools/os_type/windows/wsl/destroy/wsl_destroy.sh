
function destroy_wsl_distro() {
    if [ ! -z "$1" ]; then
        echo -e "${GREEN}Enter the name of the distribution to unregister${NC}"
        read -p "(delete): " DISTRO_NAME        
    else
        DISTRO_NAME="FedoraLinux-43" 
    fi

    echo -e "${MAGENTA}Unregistering (deleting) WSL distribution: $DISTRO_NAME${NC}"
    echo
    wsl.exe -t "$DISTRO_NAME"
    wsl.exe --unregister "$DISTRO_NAME"
    echo
    echo -e "${GREEN}Distribution $DISTRO_NAME has been unregistered.${NC}"
}