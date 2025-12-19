#!/bin/bash

function myhelp(){

    if [ "${1}" == -v ] || [ "${1}" == --version ]; then
        __verbose__=TRUE
        echo -e "${YELLOW}Verbose mode enabled.${NC}"
    fi
    

    echo -e ""
    echo -e "Description:"
    echo -e "------------------------------------------------------------------------------------------------------"
    echo -e "${MAGENTA}This functions soul purpose is to list all functions in Bashrc to help find a useful list of built in"
    echo -e "     functions to navigate the complex default functions stored in this repo!${NC}"

    echo -e ""
    _help_default_linux   
    echo -e ""

    echo -e ""
    myhelp_aws_commands
    echo -e ""

    echo -e ""
    myhelp_kubernetes
    echo -e ""


    echo -e ""
    if [ "$MATTERMOST" = "TRUE" ]; then  _help_mattermost; fi
    echo -e ""
    
    echo -e ""
    if [ "$ISWINDOWS" = "TRUE" ]; then  _help_windows; fi
    if [ "$ISWINDOWS" = "TRUE" ]; then  myhelp_wsl; fi
    echo -e ""


}

function _help_default_linux() {
    echo -e "Default Linux Systems:"
    echo -e "------------------------------------------------------------------------------------------------------"
    echo -e "     ${YELLOW}bashrc${NC}                          - Update the Bashrc in Terminal for updated changes"
    echo -e "     ${YELLOW}create_ssh${NC}                      - Create a new SSH key in your .ssh folder"
    echo -e "     ${YELLOW}gfmain${NC}                          - git fetch main:main  (Pulls origin/main to local main)"
    echo -e "     ${YELLOW}gmmain${NC}                          - git merge main"
    echo -e "     ${YELLOW}list_kubernetes_objects${NC}         - List all Kubernetes objects in a specified namespace"
    echo -e "     ${YELLOW}get_ip_address${NC}                  - Get your public IP address"
    echo -e "     ${YELLOW}show_code${NC}                       - Show the code of important configuration files"
    echo -e "     ${YELLOW}which_cluster${NC}                   - Shows which Cluster the User is connected to"

}

function _help_mattermost() {
    echo -e "Mattermost Functions:"
    echo -e "------------------------------------------------------------------------------------------------------"
    echo -e "     ${YELLOW}mattermost_functions_help${NC}       - List Mattermost functions and their descriptions"
    echo -e "     ${YELLOW}update_mattermost_ctl${NC}           - Update the Mattermost ctl Tool to the latest version"
}   

function _help_windows() {
    echo -e "Windows WSL Functions:"
    echo -e "------------------------------------------------------------------------------------------------------"
    echo -e "     ${YELLOW}destroy_wsl_distro${NC}              - Uninstall and remove a specified WSL distribution from your system"
    echo -e "     ${YELLOW}help_wsl${NC}                        - Display help information for WSL-specific functions"
    echo -e "     ${YELLOW}install_wsl_tools${NC}               - Install essential tools and configurations in WSL environment"
    echo -e "     ${YELLOW}setup_wsl${NC}                       - Setup WSL environment with necessary configurations"
    echo -e "     ${YELLOW}start_minikube_wsl${NC}              - Start Minikube in WSL environment"
    echo -e "     ${YELLOW}update_wsl_environment${NC}          - Update WSL-specific configurations and scripts"
    echo -e "     ${YELLOW}windows_first_time_setup${NC}        - Run Windows first-time setup script for installing software and configuring WSL"
}