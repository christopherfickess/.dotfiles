#!/bin/bash

__os_type_dir__="${__dotfiles_dir__}/os_type"
__macos_setup_dir__="${__os_type_dir__}/macos"
__linux_setup_dir__="${__os_type_dir__}/linux"
__windows_setup_dir__="${__os_type_dir__}/windows"
__wsl_dir__="${__windows_setup_dir__}/wsl"


# Initialize tool-specific directory variables (used by setup.sh)
__aws_functions_dir__="${__sre_tools_dir__}/aws/defaults"
__aws_users_dir__="$__aws_functions_dir__/users"
__azure_functions_dir__="${__sre_tools_dir__}/azure/defaults"
__azure_users_dir__="$__azure_functions_dir__/users"
__docker_functions_dir__="${__sre_tools_dir__}/docker"
__kubernetes_functions_dir__="${__sre_tools_dir__}/kubernetes"
__python_functions_dir__="${__sre_tools_dir__}/python"

# Initialize base directory variables
# Cache OS detection (computed once, used multiple times)
function __detect_os_type() {
    # Use OSTYPE first (fastest, bash builtin variable)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
        return
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Check for WSL - use /proc/version check first (faster than wsl.exe)
        if [[ -f /proc/version ]] && grep -qi "microsoft" /proc/version 2>/dev/null; then
            echo "wsl"
        else
            echo "linux"
        fi
        return
    fi
    
    # Windows detection fallback (slower checks)
    local uname_o
    uname_o=$(uname -o 2>/dev/null)
    if [[ "$uname_o" == "Msys" ]] || [[ "$uname_o" == "Cygwin" ]]; then
        echo "windows"
        return
    fi
    
    # Final WSL check (slowest - external command)
    if command -v wsl.exe &>/dev/null && wsl.exe --status &>/dev/null 2>&1; then
        echo "wsl"
        return
    fi
    
    echo "unknown"
}

# Cache OS type detection
__OS_TYPE=$(__detect_os_type)
unset -f __detect_os_type  # Clean up function after use

function __source_env_functions() {
    # This is to source key values for the SRE tools and hidden dotfiles and users
    [[ -f "$__bash_config_dir__/env.sh" ]] && source "$__bash_config_dir__/env.sh"
    [[ -f "$__bash_config_dir__/public_env.sh" ]] && source "$__bash_config_dir__/public_env.sh"
    [[ -f "$__bash_config_dir__/tmp/env.sh" ]] && source "$__bash_config_dir__/tmp/env.sh"

    unset -f __source_env_functions  # Clean up function after use
}

function __source_bashrc_functions() {
    [[ -f /etc/bashrc ]] && source /etc/bashrc
    [[ -f "$__bash_config_dir__/.bash_aliases" ]] && source "$__bash_config_dir__/.bash_aliases"
    [[ -f "$__bash_config_dir__/.bash_functions" ]] && source "$__bash_config_dir__/.bash_functions"

    unset -f __source_bashrc_functions  # Clean up function after use
}


function __source_os_type_functions() {
    # This is the main .bashrc file for Windows WSL setup
    # It includes functions and configurations for WSL environment setup

    case "$__OS_TYPE" in
        windows|wsl)
            ISWINDOWS="TRUE"
            
            [[ -f "$__wsl_dir__/help.sh" ]] && source "$__wsl_dir__/help.sh"

            if [[ "$__OS_TYPE" == "wsl" ]]; then
                echo -e "   ${MAGENTA}Inside WSL OS.${NC}"
                # Source WSL help functions
            else
                echo -e "   ${MAGENTA}Windows OS.${NC}"
                __WINDOWS_SETUP_CONFIG_DIR="$__windows_setup_dir__/windows_setup"
                [[ -f "$__wsl_dir__/update/wsl_update.sh" ]] && source "$__wsl_dir__/update/wsl_update.sh"
                [[ -f "$__WINDOWS_SETUP_CONFIG_DIR/first_time_setup.sh" ]] && source "$__WINDOWS_SETUP_CONFIG_DIR/first_time_setup.sh"
                [[ -f "$__wsl_dir__/help.sh" ]] && source "$__wsl_dir__/help.sh"
                [[ -f "$__wsl_dir__/destroy/wsl_destroy.sh" ]] && source "$__wsl_dir__/destroy/wsl_destroy.sh"
                [[ -f "$__wsl_dir__/setup/wsl_setup.sh" ]] && source "$__wsl_dir__/setup/wsl_setup.sh"
            fi
            ;;
        macos)
            ISMACOS="TRUE"
            # Source MacOS specific bashrc and setup scripts
            echo -e "   ${MAGENTA}MacOS OS.${NC}"
            [[ -f "$__macos_setup_dir__/macos_setup.sh" ]] && source "$__macos_setup_dir__/macos_setup.sh"
            ;;
        linux)
            ISLINUX="TRUE"
            # Source Linux specific bashrc and setup scripts
            echo -e "   ${MAGENTA}Linux OS.${NC}"
            [[ -f "$__linux_setup_dir__/linux_setup.sh" ]] && source "$__linux_setup_dir__/linux_setup.sh"
            ;;
        *)
            echo "This OS is not specifically supported by this .bashrc setup."
            ;;
    esac

    unset -f __source_os_type_functions  # Clean up function after use
    unset __os_type_dir__
    unset __macos_setup_dir__
    unset __linux_setup_dir__
    unset __windows_setup_dir__
    unset __wsl_dir__
}

function __source_cloud_setup__() {
    # Use command -v (bash builtin) instead of --version (external command) - much faster
    if command -v aws &>/dev/null; then
        [[ -f "$__aws_functions_dir__/setup.sh" ]] && source "$__aws_functions_dir__/setup.sh"
    fi
    echo "Sourcing Azure setup..."

    if command -v az &>/dev/null; then
        [[ -f "$__azure_functions_dir__/setup.sh" ]] && source "$__azure_functions_dir__/setup.sh"
    fi

    unset -f __source_cloud_setup__  # Clean up function after use
    unset __aws_functions_dir__
    unset __azure_functions_dir__
}

function __source_docker_functions() {
    # Use command -v (bash builtin) instead of --version (external command) - much faster
    if command -v docker &>/dev/null; then
        [[ -f "$__docker_functions_dir__/defaults/docker_functions.sh" ]] && source "$__docker_functions_dir__/defaults/docker_functions.sh"
        [[ -f "$__docker_functions_dir__/help.sh" ]] && source "$__docker_functions_dir__/help.sh"
    fi

    unset -f __source_docker_functions  # Clean up function after use
    unset __docker_functions_dir__
}

function __source_kubernetes_functions() {
    # Use command -v (bash builtin) instead of version --client (external command) - much faster
    if command -v kubectl &>/dev/null; then
        [[ -f "$__kubernetes_functions_dir__/defaults/kubernetes_functions.sh" ]] && source "$__kubernetes_functions_dir__/defaults/kubernetes_functions.sh"
        [[ -f "$__kubernetes_functions_dir__/help.sh" ]] && source "$__kubernetes_functions_dir__/help.sh"
    fi
    unset -f __source_kubernetes_functions  # Clean up function after use
    unset __kubernetes_functions_dir__
}

function __source_git_functions() {
    # Use command -v (bash builtin) instead of --version (external command) - much faster
    if command -v git &>/dev/null; then
        [[ -f "$__bash_config_dir__/git_files/gitconfig.sh" ]] && source "$__bash_config_dir__/git_files/gitconfig.sh"
        [[ -f "$__bash_config_dir__/git_files/git_functions.sh" ]] && source "$__bash_config_dir__/git_files/git_functions.sh"
        [[ -f "$__bash_config_dir__/git_files/help.sh" ]] && source "$__bash_config_dir__/git_files/help.sh"
        [[ -f "$__bash_config_dir__/git_files/git_creds_broken.sh" ]] && source "$__bash_config_dir__/git_files/git_creds_broken.sh"
    fi
    unset -f __source_git_functions  # Clean up function after use
}

function __source_default_python() {
    if command -v python &>/dev/null; then 
        [[ -f "${__python_functions_dir__}/help.sh" ]] && source "${__python_functions_dir__}/help.sh";
        [[ -f "${__python_functions_dir__}/defaults/python-functions.sh" ]] && source "${__python_functions_dir__}/defaults/python-functions.sh";
    fi
    
    unset -f __source_default_python  # Clean up function after use
    unset __python_functions_dir__
}

function reload_sre_tools() {
    [[ -f "${__sre_tools_dir__}/setup.sh" ]] && source "${__sre_tools_dir__}/setup.sh"
    [[ -f "${__sre_tools_dir__}/help.sh" ]] && source "${__sre_tools_dir__}/help.sh"
}

# Source functions in order
__source_bashrc_functions
__source_env_functions
__source_os_type_functions
__source_git_functions
__source_cloud_setup__
__source_docker_functions
__source_kubernetes_functions
__source_default_python
reload_sre_tools

