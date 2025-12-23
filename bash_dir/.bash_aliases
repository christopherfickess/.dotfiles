#!/bin/bash

alias cd='pushd ';
export RED='\033[0;31m';
export GREEN='\033[0;32m';
export YELLOW='\033[0;33m';
export BLUE='\033[0;34m';
export MAGENTA='\033[0;35m';
export CYAN='\033[0;36m';
export NC='\033[0m' 

# No color 
# Use these variables when adding color to the read question in a do-while loop export 
export REDR=$(tput setaf 1) #red used in a while loop after 'read';
export GREENR=$(tput setaf 2) #green used in a while loop after 'read';
export YELLOWR=$(tput setaf 3) #yellow used in a while loop after 'read';
export BLUER=$(tput setaf 4) #blue used in a while loop after 'read';
export MAGENTAR=$(tput setaf 5) #magenta used in a while loop after 'read';
export CYANR=$(tput setaf 6) #cyan used in a while loop after 'read';
export NCR=$(tput sgr0) #No color used in a while loop after 'read';


alias ls='ls --color=auto'
alias la="ls -a -1 --color"; 
alias ll="ls -al -1 --color"; 

alias grep='grep --color=auto'

alias cd="pushd ";

alias ...="cd ../..";
alias ....="cd ../../..";
alias .....="cd ../../../..";

alias gs="git status";

alias connect="code ~/.aws/credentials; code ~/.aws/config";

alias dotfiles="code $HOME/.dotfiles";

alias kubectl="kubecolor";


unset -f kubecolor 