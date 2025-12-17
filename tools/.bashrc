#!/bin/bash

__WINDOWS_SETUP_DIR="$HOME/.dotfiles/tools/os_type/windows"
__WSL_SETUP_DIR="$HOME/.dotfiles/tools/os_type/windows/wsl"
__MACOS_SETUP_DIR="$HOME/.dotfiles/tools/os_type/macos"
__LINUX_SETUP_DIR="$HOME/.dotfiles/tools/os_type/linux"
__BASH_CONFIG_DIR="$HOME/.dotfiles/tools/bash_config"
__KUBERNETES_FUNCTIONS_DIR="$HOME/.dotfiles/tools/bash_config/kubernetes_functions"
__MATTERMOST_DIR="$HOME/.dotfiles/tools/mattermost"
__AWS_FUNCTIONS_DIR="$HOME/.dotfiles/tools/aws"

# Base ENV Setup for Bash Shells
if [ -f "$__TOOLS_DIR/env.sh" ]; then  source "$__TOOLS_DIR/env.sh"; fi

# This is to source Hidden Dotfiles
if [ -f "$__TOOLS_DIR/tmp/env.sh" ]; then  source "$__TOOLS_DIR/tmp/env.sh"; fi
if [ -f "$__TOOLS_DIR/tmp/users.sh" ]; then  source "$__TOOLS_DIR/tmp/users.sh"; fi

# Standard .bashrc file content
# Source global definitions
if [ -f /etc/bashrc ]; then source /etc/bashrc; fi
if [ -f "$__BASH_CONFIG_DIR/.bash_aliases" ]; then  source "$__BASH_CONFIG_DIR/.bash_aliases"; fi
if [ -f "$__BASH_CONFIG_DIR/.bash_functions" ]; then  source "$__BASH_CONFIG_DIR/.bash_functions"; fi

if kubectl version --client &> /dev/null; then
    if [ -f "$__KUBERNETES_FUNCTIONS_DIR/kubernetes_functions.sh" ]; then  source "$__KUBERNETES_FUNCTIONS_DIR/kubernetes_functions.sh"; fi
fi
# This is the main .bashrc file for Windows WSL setup
# It includes functions and configurations for WSL environment setup

# If on Windows, source Windows specific setup scripts
# Check if Windows OS and source windows specific bashrc
if grep -qi "microsoft" /proc/version 2>/dev/null || [[ "$(uname -o 2>/dev/null)" == "Msys" ]] || [[ "$(uname -o 2>/dev/null)" == "Cygwin" ]]; then
    if [ -f "$__WINDOWS_SETUP_DIR/windows_setup/windows_first_time_setup.sh" ]; then  source "$__WINDOWS_SETUP_DIR/windows_setup/windows_first_time_setup.sh"; fi

    # Source WSL specific bashrc and setup scripts
    if [ -f "$__WSL_SETUP_DIR/wsl_setup.sh" ]; then  source "$__WSL_SETUP_DIR/wsl_setup.sh"; fi
    if [ -f "$__WSL_SETUP_DIR/wsl_help.sh" ]; then  source "$__WSL_SETUP_DIR/wsl_help.sh"; fi
    if [ -f "$__WSL_SETUP_DIR/wsl_update.sh" ]; then  source "$__WSL_SETUP_DIR/wsl_update.sh"; fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # Source MacOS specific bashrc and setup scripts
    if [ -f "$__MACOS_SETUP_DIR/macos_setup.sh" ]; then  source "$__MACOS_SETUP_DIR/macos_setup.sh"; fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Source Linux specific bashrc and setup scripts
    if [ -f "$__LINUX_SETUP_DIR/linux_setup.sh" ]; then  source "$__LINUX_SETUP_DIR/linux_setup.sh"; fi
elif wsl.exe sh -c "grep -qi 'microsoft' /proc/version" &> /dev/null; then
    # Source WSL specific bashrc and setup scripts
    if [ -f "$__WSL_SETUP_DIR/wsl_setup.sh" ]; then  source "$__WSL_SETUP_DIR/wsl_setup.sh"; fi
    if [ -f "$__WSL_SETUP_DIR/wsl_help.sh" ]; then  source "$__WSL_SETUP_DIR/wsl_help.sh"; fi
    if [ -f "$__WSL_SETUP_DIR/wsl_update.sh" ]; then  source "$__WSL_SETUP_DIR/wsl_update.sh"; fi
else
    echo "This OS is not specifically supported by this .bashrc setup."
fi


# Source Mattermost setup scripts if enabled
if [ "$MATTERMOST" = "TRUE" ];then
    if [ -f "$__MATTERMOST_DIR/mattermost.sh" ]; then  source "$__MATTERMOST_DIR/mattermost.sh"; fi
elif [ "$MATTERMOSTFED" = "TRUE" ]; then
    if [ -f "$__MATTERMOST_DIR/mattermostfed.sh" ]; then  source "$__MATTERMOST_DIR/mattermostfed.sh"; fi
fi

# Source AWS functions if AWS CLI is installed
if aws --version &> /dev/null; then
    if [ -f "$__AWS_FUNCTIONS_DIR/aws_functions.sh" ]; then  source "$__AWS_FUNCTIONS_DIR/aws_functions.sh"; fi
    if [ -f "$__AWS_FUNCTIONS_DIR/aws_connect.sh" ]; then  source "$__AWS_FUNCTIONS_DIR/aws_connect.sh"; fi
fi