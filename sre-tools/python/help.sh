

function myhelp_python(){
    echo -e "${CYAN}Python Tools:${NC}"
    echo -e "------------------------------------------------------------------------------------------------------"

    if [[ "$__verbose__" = TRUE ]]; then
        echo -e "     ${YELLOW}disable_python_env${NC} <name>       - Deactivate Python ENV"
        echo -e "     ${YELLOW}python_env_info${NC} <name>          - Tells information about Python ENV"
        echo -e "     ${YELLOW}setup_python_env${NC} <name>         - Activate Python ENV"
    else    
        echo -e "     ${YELLOW}disable_python_env${NC} <name>       - Deactivate Python ENV"
        echo -e "     ${YELLOW}setup_python_env${NC} <name>         - Activate Python ENV"
    fi
}
