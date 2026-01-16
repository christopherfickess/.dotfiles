__azure_functions_dir__="${__sre_tools_dir__}/azure/defaults"
__azure_users_dir__="$__azure_functions_dir__/users"

function __source_azure_functions__() {
    # Use command -v (bash builtin) instead of --version (external command) - much faster
    if command -v az &>/dev/null; then
        [[ -f "$__azure_functions_dir__/azure_functions.sh" ]] && source "$__azure_functions_dir__/azure_functions.sh"
        [[ -f "$__azure_functions_dir__/azure_connect.sh" ]] && source "$__azure_functions_dir__/azure_connect.sh"
        [[ -f "$__azure_functions_dir__/help.sh" ]] && source "$__azure_functions_dir__/help.sh"
        [[ -f "$__azure_users_dir__/tsl_connections.sh" ]] && source "$__azure_users_dir__/tsl_connections.sh"
        [[ -f "$__azure_users_dir__/users.sh" ]] && source "$__azure_users_dir__/users.sh";
    fi

    unset -f __source_azure_functions  # Clean up function after use
    unset __azure_functions_dir__
    unset __azure_users_dir__
}

__source_azure_functions__