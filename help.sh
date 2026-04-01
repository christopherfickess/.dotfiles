#!/bin/bash

function __color_help__() {
    export __HEADER_COLOR__="${WHITE}"
    export __CATEGORY_COLOR__="${CYAN}"
    export __COMMAND_COLOR__="${YELLOW}"
    export __DESCRIPTION_COLOR__="${WHITE}"
    export __DETAILS_COLOR__="${GREEN}"
    export __INFO_COLOR__="${MAGENTA}"
}

# Main help function - shows all available functions
function myhelp(){
    __color_help__
    local show_all=false
    local show_system=false
    local show_git=false
    local show_aws=false
    local show_azure=false
    local show_kubernetes=false
    local show_mattermost=false
    local show_wsl=false
    local show_python=false
    local show_zellij=false
    local category_count=0

    # Parse arguments
    for arg in "$@"; do
        case "$arg" in
            -v|--verbose|--advanced)
                export SRE_TOOLS_VERBOSE=true
                ;;
            --all)
                show_all=true
                ;;
            --system)
                show_system=true
                ((category_count++))
                ;;
            --aws)
                show_aws=true
                ((category_count++))
                ;;
            --azure)
                show_azure=true
                ((category_count++))
                ;;
            --kubernetes|--k8s)
                show_kubernetes=true
                ((category_count++))
                ;;
            --mattermost)
                show_mattermost=true
                ((category_count++))
                ;;
            --wsl)
                show_wsl=true
                ((category_count++))
                ;;
            --python)
                show_python=true
                ((category_count++))
                ;;
            --zellij)
                show_zellij=true
                ((category_count++))
                ;;
        esac
    done

    # If --all flag is set, show everything
    if [ "$show_all" = true ]; then
        category_count=1  # Set to non-zero to trigger full output
        show_system=true
        show_aws=true
        show_azure=true
        show_kubernetes=true
        show_mattermost=true
        show_wsl=true
        show_python=true
        show_zellij=true
    fi

    

    
    # If no categories specified, show summary
    if [ $category_count -eq 0 ]; then    
        echo ""
        echo -e "${__HEADER_COLOR__}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${__HEADER_COLOR__} Dotfiles - Unified Help System${NC}"
        echo -e "${__HEADER_COLOR__}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        __myhelp_summary__
        echo ""
        echo -e "${__DESCRIPTION_COLOR__}Usage:${NC}"
        echo -e "  ${__COMMAND_COLOR__}myhelp --all${NC}                   Show all available commands"
        echo -e "  ${__COMMAND_COLOR__}myhelp --<category>${NC}            Show specific category (e.g., --aws, --git)"
        echo -e "  ${__COMMAND_COLOR__}myhelp -v${NC} or ${__COMMAND_COLOR__}--advanced${NC}        Show advanced commands (use with categories)"
        echo ""
        echo -e "${__DESCRIPTION_COLOR__}Examples:${NC}"
        echo -e "  ${__COMMAND_COLOR__}myhelp --aws${NC}                   Show AWS commands"
        echo -e "  ${__COMMAND_COLOR__}myhelp --aws --advanced${NC}        Show AWS commands with advanced options"
        echo -e "  ${__COMMAND_COLOR__}myhelp --git --kubernetes${NC}      Show Git and Kubernetes commands"
        echo ""

        unset SRE_TOOLS_VERBOSE 2>/dev/null
        return
    fi

    echo -e "${__DESCRIPTION_COLOR__}This help system lists all functions available in your dotfiles.${NC}"
    echo ""

    # Core system functions
    if [ "$show_system" = true ] || [ "$show_all" = true ]; then
        __myhelp_default_linux__
        echo ""
        myhelp_git
        echo ""
    fi

    # AWS functions (if aws CLI is installed)
    if ([ "$show_aws" = true ] || [ "$show_all" = true ]) && command -v aws &>/dev/null; then
        if type myhelp_aws &>/dev/null; then
            myhelp_aws
            echo ""
        fi
    fi

    # Azure functions (if az CLI is installed)
    if ([ "$show_azure" = true ] || [ "$show_all" = true ]) && command -v az &>/dev/null; then
        if type myhelp_azure &>/dev/null; then
            myhelp_azure
            echo ""
        fi
    fi

    # Kubernetes functions (if kubectl is installed)
    if ([ "$show_kubernetes" = true ] || [ "$show_all" = true ]) && command -v kubectl &>/dev/null; then
        if type myhelp_kubernetes &>/dev/null; then
            myhelp_kubernetes
            echo ""
        fi
    fi

    # Mattermost functions (if enabled)
    if ([ "$show_mattermost" = true ] || [ "$show_all" = true ]) && [ "$MATTERMOST" = "TRUE" ] && [ "$MM_ENABLED" = "TRUE" ]; then
        if type myhelp_mattermost &>/dev/null; then
            myhelp_mattermost
            echo ""
        fi
    fi

    # Windows/WSL functions (Windows only)
    if ([ "$show_wsl" = true ] || [ "$show_all" = true ]) && [ "$ISWINDOWS" = "TRUE" ]; then
        __myhelp_windows__
        echo ""
        if type myhelp_wsl &>/dev/null; then
            myhelp_wsl
            echo ""
        fi
    fi

    # Python functions (if python is installed)
    if ([ "$show_python" = true ] || [ "$show_all" = true ]) && (command -v python &>/dev/null || command -v python3 &>/dev/null); then
        if type myhelp_python &>/dev/null; then
            myhelp_python
            echo ""
        fi
    fi

    # Zellij functions (if loaded)
    if ([ "$show_zellij" = true ] || [ "$show_all" = true ]) && [[ "${__SRE_TOOLS_LOADED__[zellij]}" == "true" ]]; then
        if type myhelp_zellij &>/dev/null; then
            myhelp_zellij
            echo ""
        fi
    fi

    # Show tip about verbose mode if not already enabled
    if [[ "${SRE_TOOLS_VERBOSE}" != "true" ]]; then
        echo -e "${__COMMAND_COLOR__}Tip:${NC} Add ${GREEN}-v${NC} or ${GREEN}--advanced${NC} flag for advanced commands"
        echo ""
    fi

    unset SRE_TOOLS_VERBOSE 2>/dev/null
}

# Summary mode - shows available categories
function __myhelp_summary__() {
    echo -e "${BOLD}Available Categories:${NC}"
    echo ""

    # Always available
    echo -e "  ${__CATEGORY_COLOR__}--system${NC}                     Core system functions and utilities"

    if command -v aws &>/dev/null; then
        echo -e "  ${__CATEGORY_COLOR__}--aws${NC}                        AWS cloud platform functions"
    fi

    if command -v az &>/dev/null; then
        echo -e "  ${__CATEGORY_COLOR__}--azure${NC}                      Azure cloud platform functions"
    fi

    if command -v kubectl &>/dev/null; then
        echo -e "  ${__CATEGORY_COLOR__}--kubernetes${NC} (--k8s)         Kubernetes orchestration functions"
    fi

    if [ "$MATTERMOST" = "TRUE" ] && [ "$MM_ENABLED" = "TRUE" ] && type myhelp_mattermost &>/dev/null; then
        echo -e "  ${__CATEGORY_COLOR__}--mattermost${NC}                 Mattermost chat functions"
    fi

    if [ "$ISWINDOWS" = "TRUE" ]; then
        echo -e "  ${__CATEGORY_COLOR__}--wsl${NC}                        Windows Subsystem for Linux functions"
    fi

    if command -v python &>/dev/null || command -v python3 &>/dev/null; then
        echo -e "  ${__CATEGORY_COLOR__}--python${NC}                     Python development functions"
    fi

    if [[ "${__SRE_TOOLS_LOADED__[zellij]}" == "true" ]]; then
        echo -e "  ${__CATEGORY_COLOR__}--zellij${NC}                     Zellij terminal workspace functions"
    fi
}

# Default Linux system functions
function __myhelp_default_linux__() {
    echo -e "${__HEADER_COLOR__}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${__HEADER_COLOR__} Core System Functions${NC}"
    echo -e "${__HEADER_COLOR__}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${BOLD}Common Commands:${NC}"
    echo -e "  ${__COMMAND_COLOR__}bashrc${NC}                       Reload Bashrc configuration"
    echo -e "  ${__COMMAND_COLOR__}create_ssh${NC}                   Create new SSH key"
    echo -e "  ${__COMMAND_COLOR__}get_ip_address${NC}               Show public IP address"
    echo -e "  ${__COMMAND_COLOR__}show_code${NC}                    Show configuration files"

    if [[ "${SRE_TOOLS_VERBOSE:-false}" == "true" ]]; then
        echo ""
        echo -e "${BOLD}Advanced Commands:${NC}"
        echo -e "  ${__COMMAND_COLOR__}list_kubernetes_objects${NC}      List all K8s objects in namespace"
        echo -e "  ${__COMMAND_COLOR__}which_cluster${NC}                Show current cluster context"
    fi
}

# Windows-specific functions
function __myhelp_windows__() {
    echo -e "${__HEADER_COLOR__}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${__HEADER_COLOR__} Windows WSL Functions${NC}"
    echo -e "${__HEADER_COLOR__}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${BOLD}Common Commands:${NC}"
    echo -e "  ${__COMMAND_COLOR__}setup_wsl${NC}                    Setup WSL environment"
    echo -e "  ${__COMMAND_COLOR__}install_wsl_tools${NC}            Install essential WSL tools"
    echo -e "  ${__COMMAND_COLOR__}start_minikube_wsl${NC}           Start Minikube in WSL"

    if [[ "${SRE_TOOLS_VERBOSE:-false}" == "true" ]]; then
        echo ""
        echo -e "${BOLD}Advanced Commands:${NC}"
        echo -e "  ${__COMMAND_COLOR__}destroy_wsl_distro${NC}           Uninstall WSL distribution"
        echo -e "  ${__COMMAND_COLOR__}update_wsl_environment${NC}       Update WSL configurations"
        echo -e "  ${__COMMAND_COLOR__}windows_first_time_setup${NC}     First-time Windows setup"
        echo ""
        echo -e "${BOLD}Advanced Windows Tools:${NC}"
        echo -e "  ${__COMMAND_COLOR__}cleanup_old_bash_processes${NC}   Clean up old processes"
        echo -e "  ${__COMMAND_COLOR__}count_terminals_open${NC}         Count open terminals"
        echo -e "  ${__COMMAND_COLOR__}show_terminals_time${NC}          Show terminal start times"
    fi
}

# Git functions help
function myhelp_git() {
    echo -e "${BOLD}Git Functions:${NC}"
    echo -e "  ${__COMMAND_COLOR__}clear_credentials_manager${NC}    Clear Git credentials from Windows Credential Manager."
    echo -e "  ${__COMMAND_COLOR__}config_git [name] [email]${NC}    Configure Git user settings"
    echo -e "  ${__COMMAND_COLOR__}gfmain${NC}                       git fetch main:main"
    echo -e "  ${__COMMAND_COLOR__}gmmain${NC}                       git merge main"
    
    if [[ "${SRE_TOOLS_VERBOSE:-false}" == "true" ]]; then
        echo ""
        echo -e "${BOLD}Advanced Commands:${NC}"
        echo -e "  ${__COMMAND_COLOR__}git lsg${NC}                  Display pretty graph log of commits."
        echo -e "  ${__COMMAND_COLOR__}git last${NC}                 Show the last commit details."
        echo -e "  ${__COMMAND_COLOR__}git lg${NC}                   Show a one-line graph"
        echo -e "  ${__COMMAND_COLOR__}git prune-tags${NC}           Prune deleted tags from remote."
        echo -e "  ${__COMMAND_COLOR__}git amend${NC}                Amend the last commit without changing the message."
    fi
}
