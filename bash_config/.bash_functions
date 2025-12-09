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

function gfmain() { 
    git fetch origin main:main
} 

function gmmain() { 
    git merge main 
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

# ------------------
# Secret Functions
# ------------------
function _git_config_setup() {
    echo -e "🔧 ${CYANR}Setting up your global Git configuration...${NC}"
    echo

    # Ask for user name and email if not provided as args
    if [[ -z "$1" ]]; then
        echo -en "${GREEN}Enter your Git user name${NC}"
        read -p ": " GIT_NAME
    else
        GIT_NAME="$1"
    fi

    if [[ -z "$2" ]]; then
        echo -en "${GREEN}Enter your Git user email${NC}"
        read -p ": " GIT_EMAIL
    else
        GIT_EMAIL="$2"
    fi

    # Confirm values
    echo
    echo "✅ Using:"
    echo "   Name : $GIT_NAME"
    echo "   Email: $GIT_EMAIL"
    echo
    read -p "Proceed with these values? (y/n): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "❌ Aborted."
        return 1
    fi

    # Set configs
    git config --global user.name "$GIT_NAME"
    git config --global user.email "$GIT_EMAIL"

    git config --global alias.lsg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
    git config --global alias.prune-tags "fetch --prune origin '+refs/tags/*:refs/tags/*'";
    git config --global alias.s "status -sb";
    git config --global alias.co "checkout";
    git config --global alias.br "branch";
    git config --global alias.last "log -1 HEAD";
    git config --global alias.lg "log --oneline --graph --decorate --all";
    git config --global alias.amend "commit --amend --no-edit";
    git config --global user.email "christopher.a.fickess@boeing.com";
    git config --global user.name "christopher.a.fickess";
    git config --global init.defaultBranch "main";
    git config --global color.ui true;
    git config --global help.autocorrect 1;
    git config --global diff.tool code;
    git config --global rerere.enabled false;
    git config --global rerere.autoUpdate false;
    git config --global core.excludesfile ~/.dotfiles/.gitignore;
    git config --global fetch.prune true;
    git config --global push.default current
} 
