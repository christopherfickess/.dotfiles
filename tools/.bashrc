#!/bin/bash

__TOOLS_DIR="$HOME/.dotfiles/tools"
__BASH_CONFIG_DIR="${__TOOLS_DIR}/bash_config"
__OS_TYPE_DIR="${__TOOLS_DIR}/os_type"
__MACOS_SETUP_DIR="${__OS_TYPE_DIR}/macos"
__LINUX_SETUP_DIR="${__OS_TYPE_DIR}/linux"
__WINDOWS_SETUP_DIR="${__OS_TYPE_DIR}/windows"
__WSL_SETUP_DIR="${__WINDOWS_SETUP_DIR}/wsl"

function __source_env_functions() {
    # This is to source key values for the SRE tools and hidden dotfiles and users
    if [ -f "$__TOOLS_DIR/env.sh" ]; then  source "$__TOOLS_DIR/env.sh"; fi
    if [ -f "$__TOOLS_DIR/tmp/env.sh" ]; then  source "$__TOOLS_DIR/tmp/env.sh"; fi
    if [ -f "$__TOOLS_DIR/tmp/users.sh" ]; then  source "$__TOOLS_DIR/tmp/users.sh"; fi
}

function __source_bashrc_functions() {
    if [ -f /etc/bashrc ]; then source /etc/bashrc; fi
    if [ -f "$__BASH_CONFIG_DIR/.bash_aliases" ]; then  source "$__BASH_CONFIG_DIR/.bash_aliases"; fi
    if [ -f "$__BASH_CONFIG_DIR/.bash_functions" ]; then  source "$__BASH_CONFIG_DIR/.bash_functions"; fi
}


function __source_os_type_functions() {
    # This is the main .bashrc file for Windows WSL setup
    # It includes functions and configurations for WSL environment setup

    # If on Windows, source Windows specific setup scripts
    # Check if Windows OS and source windows specific bashrc
    if grep -qi "microsoft" /proc/version 2>/dev/null || [[ "$(uname -o 2>/dev/null)" == "Msys" ]] || [[ "$(uname -o 2>/dev/null)" == "Cygwin" ]]; then
        echo -e "   ${MAGENTA}Detected Windows OS.${NC}"
        ISWINDOWS="TRUE"

        if [ -f "$__WINDOWS_SETUP_DIR/windows_setup/windows_first_time_setup.sh" ]; then  source "$__WINDOWS_SETUP_DIR/windows_setup/windows_first_time_setup.sh"; fi

        if [[ -n "$WSL_DISTRO_NAME" ]]; then
            echo -e "   ${CYAN}Inside wsl.${NC}"
            if [ -f "$__WSL_SETUP_DIR/setup/wsl_setup.sh" ]; then  source "$__WSL_SETUP_DIR/setup/wsl_setup.sh"; fi
        elif wsl.exe --status &> /dev/null; then
            echo -e "   ${MAGENTA}Detected WSL Environment.${NC}"
            if [ -f "$__WSL_SETUP_DIR/update/wsl_update.sh" ]; then  source "$__WSL_SETUP_DIR/update/wsl_update.sh"; fi
            
            if [ -f "$__WSL_SETUP_DIR/destroy/wsl_destroy.sh" ]; then  source "$__WSL_SETUP_DIR/destroy/wsl_destroy.sh"; fi
        else 
            echo -e "   ${CYAN}WSL Environment not detected.${NC}"
            if [ -f "$__WSL_SETUP_DIR/setup/wsl_setup.sh" ]; then  source "$__WSL_SETUP_DIR/setup/wsl_setup.sh"; fi
        fi
        if [ -f "$__WSL_SETUP_DIR/wsl_help.sh" ]; then  source "$__WSL_SETUP_DIR/wsl_help.sh"; fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # Source MacOS specific bashrc and setup scripts
        ISMACOS="TRUE"
        if [ -f "$__MACOS_SETUP_DIR/macos_setup.sh" ]; then  source "$__MACOS_SETUP_DIR/macos_setup.sh"; fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        ISLINUX="TRUE"
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
}


function __source_aws_functions() {
    
    if aws --version &> /dev/null; then
        __AWS_FUNCTIONS_FILE="${__AWS_FUNCTIONS_DIR}/aws_functions.sh"
        __AWS_CONNECT_FILE="${__AWS_FUNCTIONS_DIR}/aws_connect.sh"
        __AWS_HELP_FILE="${__AWS_FUNCTIONS_DIR}/help.sh"

        if [ -f "${__AWS_FUNCTIONS_FILE}" ]; then source "${__AWS_FUNCTIONS_FILE}";  fi
        if [ -f "${__AWS_CONNECT_FILE}" ]; then source "${__AWS_CONNECT_FILE}";  fi
        if [ -f "${__AWS_HELP_FILE}" ]; then source "${__AWS_HELP_FILE}";  fi
    fi
}

function __source_docker_functions() {
    if docker --version &> /dev/null; then
        __DOCKER_FUNCTIONS_FILE="${__DOCKER_FUNCTIONS_DIR}/docker_functions.sh"
        __DOCKER_HELP_FILE="${__DOCKER_FUNCTIONS_DIR}/help.sh"
        if [ -f "${__DOCKER_FUNCTIONS_FILE}" ]; then source "${__DOCKER_FUNCTIONS_FILE}";  fi
        if [ -f "${__DOCKER_HELP_FILE}" ]; then source "${__DOCKER_HELP_FILE}";  fi
    fi
}

function __source_kubernetes_functions() {
    if kubectl version --client &> /dev/null; then
        __KUBERNETES_FUNCTION_FILE="${__KUBERNETES_FUNCTIONS_DIR}/kubernetes_functions.sh"
        __KUBERNETES_HELP_FILE="${__KUBERNETES_FUNCTIONS_DIR}/help.sh"
        if [ -f "${__KUBERNETES_FUNCTION_FILE}" ]; then source "${__KUBERNETES_FUNCTION_FILE}";  fi
        if [ -f "${__KUBERNETES_HELP_FILE}" ]; then source "${__KUBERNETES_HELP_FILE}";  fi
    fi
}

function setup_sre_tools() {
    if [ -f "$__TOOLS_DIR/setup.sh" ]; then  source "$__TOOLS_DIR/setup.sh"; fi
}


__source_bashrc_functions
__source_env_functions
__source_os_type_functions
__source_aws_functions
__source_docker_functions
__source_kubernetes_functions
setup_sre_tools

