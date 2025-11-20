#!/bin/bash

function help_function(){
    echo -e ""
    echo -e "Description:"
    echo -e "------------------------------------------------------------------------------------------------------"
    echo -e "${MAGENTA}This functions soul purpose is to list all functions in Bashrc to help find a useful"
    echo -e "     list of built in functions to navigate the complex default functions stored in this repo!${NC}"

    echo -e ""
    echo -e "Default Linux Systems"
    echo -e "------------------------------------------------------------------------------------------------------"
    echo -e "     ${YELLOW}which_cluster${NC}           - Shows which Cluster the User is connected to"
    echo -e "     ${YELLOW}bashrc${NC}                  - Update the Bashrc in Terminal for updated changes"
    echo -e "     ${YELLOW}gfmain${NC}                  - git fetch main:main  (Pulls origin/main to local main)"
    echo -e "     ${YELLOW}gmmain${NC}                  - git merge main"
    echo -e "     ${YELLOW}_git_config_setup${NC}       - Configure your default git config --global settings"
    

    echo -e ""
}