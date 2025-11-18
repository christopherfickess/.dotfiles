#!/bin/bash

if [ -f "$HOME/.dotfiles/.bash_functions" ]; then  source "$HOME/.dotfiles/.bash_functions"; fi
if [ -f "$HOME/.dotfiles/.bash_aliases" ]; then  source "$HOME/.dotfiles/.bash_aliases"; fi
if [ -f "$HOME/.dotfiles/aws/kubernetes_functions.sh" ]; then  source "$HOME/.dotfiles/aws/kubernetes_functions.sh"; fi
if [ -f "$HOME/.dotfiles/aws/aws_functions.sh" ]; then  source "$HOME/.dotfiles/aws/aws_functions.sh"; fi
if [ -f "$HOME/.dotfiles/tools/.bashrc" ]; then  source "$HOME/.dotfiles/tools/.bashrc"; fi
if [ -f "$HOME/.dotfiles/tmp/env.sh" ]; then  source "$HOME/.dotfiles/tmp/env.sh"; fi

# Check if Windows OS and source windows specific bashrc
if grep -qi "microsoft" /proc/version 2>/dev/null || [[ "$(uname -o 2>/dev/null)" == "Msys" ]] || [[ "$(uname -o 2>/dev/null)" == "Cygwin" ]]; then
    if [ -f "$HOME/.dotfiles/windows/.bashrc" ]; then  source "$HOME/.dotfiles/windows/.bashrc"; fi
    ISWINDOWS=TRUE;
else
    echo "This is NOT Windows"
fi

# .bashrc 
function branching_method_1 () {
    function git-branch-name {
        git symbolic-ref HEAD 2>/dev/null | cut -d "/" -f 3,4,5
    } 

    function git-branch-prompt {
        local branch=$(git-branch-name) 
        
        if [ $branch ]; then printf "%s " $branch; fi
    } 
    export PS1='\[\033[32m\]$(git-branch-prompt)\[\e[1;34m\]\w\[\033[32m\]\[\e[m\] \[\e[0;31m\]> \[\033[0m\]'
}


export PATH=$PATH:$HOME/go/bin
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:$HOME/bin

function branching_method_2() {
    # Function to get branch name
    git_branch_name() {
        git symbolic-ref --short HEAD 2>/dev/null
    }

    # Function to get ahead count
    git_branch_ahead() {
        local branch=$(git_branch_name)
        if [[ -n "$branch" ]]; then
            local upstream=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
            if [[ -n "$upstream" ]]; then
                local ahead=$(git rev-list --count "$upstream"..HEAD 2>/dev/null)
                if [[ "$ahead" -gt 0 ]]; then
                    printf "↑%s" "$ahead"
                fi
            fi
        fi
    }

    # Export PS1 with separate colors
    export PS1="\[\e[36m\]\w\[\e[0m\] \[\e[32m\][ \$(git_branch_name)\[\e[37m\] \$(git_branch_ahead)\[\e[32m\]]\[\e[0m\] \[\e[0;31m\]> \[\e[0m\]"
}

function branching_method_3() {
    # Function to get branch name (plain text)
    git_branch_name() {
        git symbolic-ref --short HEAD 2>/dev/null
    }

    # Function to get ahead/behind relative to default branch (plain text)
    git_branch_ahead_behind() {
        local branch=$(git_branch_name)
        local default_branch=""
        if git show-ref --verify --quiet refs/heads/main; then
            default_branch="main"
        elif git show-ref --verify --quiet refs/heads/master; then
            default_branch="master"
        fi

        if [[ -n "$branch" && -n "$default_branch" ]]; then
            local ahead=$(git rev-list --count "$default_branch"..HEAD 2>/dev/null)
            local behind=$(git rev-list --count HEAD.."$default_branch" 2>/dev/null)
            local str=""
            [[ "$ahead" -gt 0 ]] && str+="↑$ahead"
            [[ "$behind" -gt 0 ]] && str+="↓$behind"
            printf "%s" "$str"
        fi
    }

    # Function to build branch prompt (plain text)
    git_branch_prompt() {
        local branch=$(git_branch_name)
        if [[ -n "$branch" ]]; then
            printf "[%s%s]" "$branch" "$(git_branch_ahead_behind)"
        fi
    }

    # PS1 with colors **outside the command substitution**
    export PS1="\[\e[1;34m\]\w\[\e[0m\] \[\e[32m\] \$(git_branch_name)\[\e[0m\]\[\e[37m\] \$(git_branch_ahead_behind)\[\e[0m\] \[\e[0;31m\]> \[\e[0m\]"
}


branching_method_3
