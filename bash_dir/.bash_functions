#!/bin/bash

export HISTFILESIZE=2000000 

# The maximum number of lines contained in the history file
export HISTCONTROL=ignoredups # Ignore duplicate commands 
export HISTIGNORE="&:ls:cd:exit" # Commands to exclude from history (optional) 
shopt -s histappend;

export HISTTIMEFORMAT="%F %T " # Add timestamps to history (optional)

## Bash_functions function 
function bashrc() {
    echo -e "     Updating ${GREEN}.bashrc${NC} with latest from .dotfiles..."
    echo
    if [ -f "$HOME/.bashrc" ]; then
        source "${HOME}/.bashrc"
        echo -e "     ${MAGENTAR}.bashrc updated successfully.${NC}"
    else
        echo -e "${RED}Error: ~/.bashrc not found.${NC}"
    fi
}

function create_ssh() {
    if [ -z "${1}" ]; then 
        echo -en "${MAGENTA}Input the File Name for Key${NC}"
        read -p "  :  " __ssh_file_name
    else
        __ssh_file_name="${1}"
    fi
    
    ssh-keygen -f "${HOME}/.ssh/${__ssh_file_name}" -t ed25519 -C "christopher.fickess@mattermost.com"

}

function get_ip_address(){
    curl https://checkip.amazonaws.com
    # SSH WITH OPEN IPS then run who to see the IP address of the user
}

function show_code() {
    echo -e ""
    echo -e "Description:"
    echo -e "------------------------------------------------------------------------------------------------------"
    echo -e "${MAGENTA}This function displays the contents of a specified files listed below."
    echo -e "     Use this function to quickly view the contents of files in your terminal.${NC}"
    echo -e ""
    
    while true; do
        echo -e "Available files to view:"
        echo -e "1. ${YELLOW}.aws/credentials${NC}"
        echo -e "2. ${YELLOW}.aws/config${NC}"
        echo -e "8. Exit"
        read -p "Select a file to view (1-8): " choice

        case $choice in
            1) code ~/.aws/credentials 
                break
                ;;
            2) code ~/.aws/config 
                break
                ;;
            8) break ;;
            *) echo -e "${RED}Invalid choice, please try again.${NC}" ;;
        esac
    done
}

function speed_test() {
    echo -e "${CYAN}Running speed test...${NC}"
    time bash -lc 'exit'
}