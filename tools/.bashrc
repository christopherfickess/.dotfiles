#!/bin/bash

# Initialize base directory variables
__DOTFILES_DIR="$HOME/.dotfiles"
__TOOLS_DIR="$__DOTFILES_DIR/tools"
__SRE_TOOLS_DIR="${__DOTFILES_DIR}/sre-tools"
__BASH_CONFIG_DIR="${__DOTFILES_DIR}/bash_dir"
__OS_TYPE_DIR="${__DOTFILES_DIR}/os_type"
__MACOS_SETUP_DIR="${__OS_TYPE_DIR}/macos"
__LINUX_SETUP_DIR="${__OS_TYPE_DIR}/linux"
__WINDOWS_SETUP_DIR="${__OS_TYPE_DIR}/windows"
__WSL_SETUP_DIR="${__WINDOWS_SETUP_DIR}/wsl"

# Initialize tool-specific directory variables (used by setup.sh)
__AWS_FUNCTIONS_DIR="${__SRE_TOOLS_DIR}/aws/defaults"
__AWS_USERS_DIR="$__AWS_FUNCTIONS_DIR/users"
__DOCKER_FUNCTIONS_DIR="${__TOOLS_DIR}/docker"
__KUBERNETES_FUNCTIONS_DIR="${__TOOLS_DIR}/kubernetes"


__GCP_USERS_DIR="$__TOOLS_DIR/gcp/users"
__AZURE_USERS_DIR="$__TOOLS_DIR/azure/users"

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
    [[ -f "$__TOOLS_DIR/env.sh" ]] && source "$__BASH_CONFIG_DIR/env.sh"
    [[ -f "$__TOOLS_DIR/tmp/env.sh" ]] && source "$__BASH_CONFIG_DIR/public_env.sh"
    # [[ -f "$__TOOLS_DIR/tmp/users.sh" ]] && source "$__TOOLS_DIR/tmp/users.sh"
}

function __source_cloud_users_functions() {
    # Source cloud user functions if the file exists
    [[ -f "$__AWS_USERS_DIR/users.sh" ]] && source "$__AWS_USERS_DIR/users.sh";
    [[ -f "$__GCP_USERS_DIR/users.sh" ]] && source "$__GCP_USERS_DIR/users.sh";
    [[ -f "$__AZURE_USERS_DIR/users.sh" ]] && source "$__AZURE_USERS_DIR/users.sh";
}

function __source_bashrc_functions() {
    [[ -f /etc/bashrc ]] && source /etc/bashrc
    [[ -f "$__BASH_CONFIG_DIR/.bash_aliases" ]] && source "$__BASH_CONFIG_DIR/.bash_aliases"
    [[ -f "$__BASH_CONFIG_DIR/.bash_functions" ]] && source "$__BASH_CONFIG_DIR/.bash_functions"
}


function __source_os_type_functions() {
    # This is the main .bashrc file for Windows WSL setup
    # It includes functions and configurations for WSL environment setup

    case "$__OS_TYPE" in
        windows|wsl)
            ISWINDOWS="TRUE"

            if [[ "$__OS_TYPE" == "wsl" ]]; then
                echo -e "   ${MAGENTA}Inside WSL OS.${NC}"
                # Source WSL help functions
                [[ -f "$__WSL_SETUP_DIR/help.sh" ]] && source "$__WSL_SETUP_DIR/help.sh"
            else
                echo -e "   ${MAGENTA}Windows OS.${NC}"
                __WINDOWS_SETUP_CONFIG_DIR="$__WINDOWS_SETUP_DIR/windows_setup"
                [[ -f "$__WINDOWS_SETUP_CONFIG_DIR/windows_first_time_setup.sh" ]] && source "$__WINDOWS_SETUP_CONFIG_DIR/windows_first_time_setup.sh"
                [[ -f "$__WSL_SETUP_DIR/help.sh" ]] && source "$__WSL_SETUP_DIR/help.sh"

                # On Windows (not inside WSL) - check if WSL needs setup
                if command -v wsl.exe &>/dev/null; then
                    # Check if any WSL distro exists (Running or Stopped)
                    if ! wsl.exe -l -v 2>/dev/null | iconv -f UTF-16LE -t UTF-8 2>/dev/null | sed '1d' | grep -q "Running\|Stopped"; then
                        echo -e "   ${CYAN}WSL distribution not found. Setting up WSL...${NC}"
                        # Source wsl_setup.sh to get setup_wsl function, then call it
                        [[ -f "$__WSL_SETUP_DIR/setup/wsl_setup.sh" ]] && source "$__WSL_SETUP_DIR/setup/wsl_setup.sh" && setup_wsl
                    fi
                fi
                # Source WSL update/destroy functions if they exist
                [[ -f "$__WSL_SETUP_DIR/update/wsl_update.sh" ]] && source "$__WSL_SETUP_DIR/update/wsl_update.sh"
                [[ -f "$__WSL_SETUP_DIR/destroy/wsl_destroy.sh" ]] && source "$__WSL_SETUP_DIR/destroy/wsl_destroy.sh"
                [[ -f "$__WSL_SETUP_DIR/help.sh" ]] && source "$__WSL_SETUP_DIR/help.sh"
            fi
            ;;
        macos)
            ISMACOS="TRUE"
            # Source MacOS specific bashrc and setup scripts
            echo -e "   ${MAGENTA}MacOS OS.${NC}"
            [[ -f "$__MACOS_SETUP_DIR/macos_setup.sh" ]] && source "$__MACOS_SETUP_DIR/macos_setup.sh"
            ;;
        linux)
            ISLINUX="TRUE"
            # Source Linux specific bashrc and setup scripts
            echo -e "   ${MAGENTA}Linux OS.${NC}"
            [[ -f "$__LINUX_SETUP_DIR/linux_setup.sh" ]] && source "$__LINUX_SETUP_DIR/linux_setup.sh"
            ;;
        *)
            echo "This OS is not specifically supported by this .bashrc setup."
            ;;
    esac
}

function __source_aws_functions() {
    # Use command -v (bash builtin) instead of --version (external command) - much faster
    if command -v aws &>/dev/null; then
        [[ -f "$__AWS_FUNCTIONS_DIR/aws_functions.sh" ]] && source "$__AWS_FUNCTIONS_DIR/aws_functions.sh"
        [[ -f "$__AWS_FUNCTIONS_DIR/aws_connect.sh" ]] && source "$__AWS_FUNCTIONS_DIR/aws_connect.sh"
        [[ -f "$__AWS_FUNCTIONS_DIR/help.sh" ]] && source "$__AWS_FUNCTIONS_DIR/help.sh"
    fi
}

function __source_docker_functions() {
    # Use command -v (bash builtin) instead of --version (external command) - much faster
    if command -v docker &>/dev/null; then
        [[ -f "$__DOCKER_FUNCTIONS_DIR/docker_functions.sh" ]] && source "$__DOCKER_FUNCTIONS_DIR/docker_functions.sh"
        [[ -f "$__DOCKER_FUNCTIONS_DIR/help.sh" ]] && source "$__DOCKER_FUNCTIONS_DIR/help.sh"
    fi
}

function __source_kubernetes_functions() {
    # Use command -v (bash builtin) instead of version --client (external command) - much faster
    if command -v kubectl &>/dev/null; then
        [[ -f "$__KUBERNETES_FUNCTIONS_DIR/kubernetes_functions.sh" ]] && source "$__KUBERNETES_FUNCTIONS_DIR/kubernetes_functions.sh"
        [[ -f "$__KUBERNETES_FUNCTIONS_DIR/help.sh" ]] && source "$__KUBERNETES_FUNCTIONS_DIR/help.sh"
    fi
}

function __source_git_functions() {
    # Use command -v (bash builtin) instead of --version (external command) - much faster
    if command -v git &>/dev/null; then
        [[ -f "$__BASH_CONFIG_DIR/git_files/gitconfig.sh" ]] && source "$__BASH_CONFIG_DIR/git_files/gitconfig.sh"
        [[ -f "$__BASH_CONFIG_DIR/git_files/git_functions.sh" ]] && source "$__BASH_CONFIG_DIR/git_files/git_functions.sh"
        [[ -f "$__BASH_CONFIG_DIR/git_files/help.sh" ]] && source "$__BASH_CONFIG_DIR/git_files/help.sh"
        [[ -f "$__BASH_CONFIG_DIR/git_files/git_creds_broken.sh" ]] && source "$__BASH_CONFIG_DIR/git_files/git_creds_broken.sh"
    fi
}

function setup_sre_tools() {
    [[ -d "${__TOOLS_DIR}/sre-tools" ]] && __SRE_TOOLS_DIR="${__TOOLS_DIR}/sre-tools"
    [[ -f "$__SRE_TOOLS_DIR/setup.sh" ]] && source "$__SRE_TOOLS_DIR/setup.sh"
}

# Source functions in order
__source_bashrc_functions
__source_env_functions
__source_os_type_functions
__source_git_functions
__source_aws_functions
__source_docker_functions
__source_kubernetes_functions
__source_cloud_users_functions
setup_sre_tools

