#!/bin/bash

# This is to source Hidden Dotfiles
if [ -f "$HOME/.dotfiles/tools/tmp/env.sh" ]; then  source "$HOME/.dotfiles/tools/tmp/env.sh"; fi
if [ -f "$HOME/.dotfiles/tmp/users.sh" ]; then  source "$HOME/.dotfiles/tmp/users.sh"; fi

# Standard .bashrc file content
# Source global definitions
if [ -f /etc/bashrc ]; then source /etc/bashrc; fi
if [ -f "$HOME/.dotfiles/tools/bash_config/.bash_aliases" ]; then  source "$HOME/.dotfiles/tools/bash_config/.bash_aliases"; fi
if [ -f "$HOME/.dotfiles/tools/bash_config/.bash_functions" ]; then  source "$HOME/.dotfiles/tools/bash_config/.bash_functions"; fi

if [ -f "$HOME/.dotfiles/tools/bash_config/kubernetes_functions.sh" ]; then  source "$HOME/.dotfiles/tools/bash_config/kubernetes_functions.sh"; fi


# This is the main .bashrc file for Windows WSL setup
# It includes functions and configurations for WSL environment setup
if [ -f "$HOME/.dotfiles/tools/windows/windows_setup/windows_first_time_setup.sh" ]; then  source "$HOME/.dotfiles/tools/windows/windows_setup/windows_first_time_setup.sh"; fi

# Source WSL specific bashrc and setup scripts
if [ -f "$HOME/.dotfiles/tools/windows/wsl/wsl_setup.sh" ]; then  source "$HOME/.dotfiles/tools/windows/wsl/wsl_setup.sh"; fi
if [ -f "$HOME/.dotfiles/tools/windows/wsl/wsl_help.sh" ]; then  source "$HOME/.dotfiles/tools/windows/wsl/wsl_help.sh"; fi
if [ -f "$HOME/.dotfiles/tools/windows/wsl/wsl_update.sh" ]; then  source "$HOME/.dotfiles/tools/windows/wsl/wsl_update.sh"; fi

# Source Mattermost setup scripts if enabled
if [ -f "$HOME/.dotfiles/tools/mattermost/mattermost.sh" ] && [ "$MATTERMOST" = "TRUE" ]; then  source "$HOME/.dotfiles/tools/mattermost/mattermost.sh"; fi
if [ -f "$HOME/.dotfiles/tools/mattermost/mattermostfed.sh" ] && [ "$MATTERMOSTFED" = "TRUE" ]; then  source "$HOME/.dotfiles/tools/mattermost/mattermostfed.sh"; fi

# Source AWS functions
if [ -f "$HOME/.dotfiles/tools/aws/aws_functions.sh" ]; then  source "$HOME/.dotfiles/tools/aws/aws_functions.sh"; fi