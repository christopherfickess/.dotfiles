#!/bin/bash

## Bash_functions function 
which_cluster() { 
    kubectl config current-context 
} 

function gfmain() { 
    git fetch origin main:main
} 

function gmmain() { 
    git merge main 
} 

function git-config-setup() {
     echo "🔧 Setting up your global Git configuration..."
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

export HISTFILESIZE=2000000 

# The maximum number of lines contained in the history file
export HISTCONTROL=ignoredups # Ignore duplicate commands 
export HISTIGNORE="&:ls:cd:exit" # Commands to exclude from history (optional) 
shopt -s histappend;

export HISTTIMEFORMAT="%F %T " # Add timestamps to history (optional)

