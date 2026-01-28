#!/bin/bash

function myhelp(){

    if [ "${1}" == -v ] || [ "${1}" == --version ]; then
        __verbose__=TRUE
        echo -e "${YELLOW}Verbose mode enabled.${NC}"
    else
        __verbose__=FALSE
    fi
    

    echo -e ""
    echo -e "Description:"
    echo -e "------------------------------------------------------------------------------------------------------"
    echo -e "${MAGENTA}This functions soul purpose is to list all functions in Bashrc to help find a useful list of built in"
    echo -e "     functions to navigate the complex default functions stored in this repo!${NC}"

    echo -e ""
    __help_default_linux__   
    echo -e ""

    if command -v git &>/dev/null; then 
        echo -e ""
        help_git_functions
        echo -e ""
    fi

    if command -v aws &>/dev/null; then
        echo -e ""
        myhelp_aws
        echo -e ""
    fi

    if command -v az &>/dev/null; then
        echo -e ""
        myhelp_azure
        echo -e ""
    fi

    if command -v kubectl &>/dev/null; then
        echo -e ""
        myhelp_kubernetes
        echo -e ""
    fi

    echo -e ""
    if [ "$MATTERMOST" = "TRUE" ]; then  __help_mattermost__; fi
    echo -e ""
    
    echo -e ""
    if [ "$ISWINDOWS" = "TRUE" ]; then  __help_windows__; fi
    if [ "$ISWINDOWS" = "TRUE" ]; then  myhelp_wsl; fi
    echo -e ""

    if command -v python &>/dev/null; then
        echo -e ""
        myhelp_python
        echo -e ""
    fi

    unset __verbose__
}

function __help_default_linux__() {
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

function __help_mattermost__() {
    echo -e "Mattermost Functions:"
    echo -e "------------------------------------------------------------------------------------------------------"
    echo -e "     ${YELLOW}mattermost_functions_help${NC}       - List Mattermost functions and their descriptions"
    echo -e "     ${YELLOW}update_mattermost_ctl${NC}           - Update the Mattermost ctl Tool to the latest version"
}   

function __help_windows__() {
    echo -e "Windows WSL Functions:"
    echo -e "------------------------------------------------------------------------------------------------------"
    echo -e "     ${YELLOW}destroy_wsl_distro${NC}              - Uninstall and remove a specified WSL distribution from your system"
    echo -e "     ${YELLOW}help_wsl${NC}                        - Display help information for WSL-specific functions"
    echo -e "     ${YELLOW}install_wsl_tools${NC}               - Install essential tools and configurations in WSL environment"
    echo -e "     ${YELLOW}setup_wsl${NC}                       - Setup WSL environment with necessary configurations"
    echo -e "     ${YELLOW}start_minikube_wsl${NC}              - Start Minikube in WSL environment"
    echo -e "     ${YELLOW}update_wsl_environment${NC}          - Update WSL-specific configurations and scripts"
    echo -e "     ${YELLOW}windows_first_time_setup${NC}        - Run Windows first-time setup script for installing software and configuring WSL"
    echo -e ""
    echo -e "Advanced Windows ${MAGENTA}ONLY:${NC}"
    echo -e "------------------------------------------------------------------------------------------------------"
    echo -e "     ${YELLOW}cleanup_old_bash_processes -h${NC}   - Clean up old bash processes running longer than a specified time"
    echo -e "     ${YELLOW}count_terminals_open${NC}            - Count the number of open bash terminals"
    echo -e "     ${YELLOW}show_terminals_time${NC}             - Show start times of open bash terminals"
}