#!/bin/bash

# Source .dotfiles files

if [ -f "$HOME/.dotfiles/.bash_functions.sh" ]; then  source "$HOME/.dotfiles/.bash_functions.sh"; fi
if [ -f "$HOME/.dotfiles/.bash_aliases.sh" ]; then  source "$HOME/.dotfiles/.bash_aliases.sh"; fi
if [ -f "$HOME/.dotfiles/aws/.kubernetes_functions.sh" ]; then  source "$HOME/.dotfiles/aws/.kubernetes_functions.sh"; fi
if [ -f "$HOME/.dotfiles/aws/.aws_functions.sh" ]; then  source "$HOME/.dotfiles/aws/.aws_functions.sh"; fi


# .bashrc 
function git-branch-name {
    git symbolic-ref HEAD 2>/dev/null | cut -d "/" -f 3,4,5
} 

function git-branch-prompt {
    local branch=$(git-branch-name) 
    
    if [ $branch ]; then printf "%s " $branch; fi
} 

export PS1='\[\033[32m\]$(git-branch-prompt)\[\e[1;34m\]\w\[\033[32m\]\[\e[m\] \[\e[0;31m\]> \[\033[0m\]'