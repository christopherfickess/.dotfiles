__azure_functions_dir__="${__sre_tools_dir__}/azure/defaults"
__azure_users_dir__="$__azure_functions_dir__/users"

function __source_azure_functions__() {
    # Use command -v (bash builtin) instead of --version (external command) - much faster
    if command -v az &>/dev/null; then
        [[ -f "$__azure_functions_dir__/azure_functions.sh" ]] && source "$__azure_functions_dir__/azure_functions.sh"
        [[ -f "$__azure_functions_dir__/azure_connect.sh" ]] && source "$__azure_functions_dir__/azure_connect.sh"
        [[ -f "$__azure_functions_dir__/help.sh" ]] && source "$__azure_functions_dir__/help.sh"
        [[ -f "$__azure_functions_dir__/display.sh" ]] && source "$__azure_functions_dir__/display.sh";
        [[ -f "$__azure_functions_dir__/getters.sh" ]] && source "$__azure_functions_dir__/getters.sh";
        [[ -f "$__azure_functions_dir__/setters.sh" ]] && source "$__azure_functions_dir__/setters.sh";
        [[ -f "$__azure_functions_dir__/create.sh" ]] && source "$__azure_functions_dir__/create.sh";
        [[ -f "$__azure_users_dir__/tsl_connections.sh" ]] && source "$__azure_users_dir__/tsl_connections.sh"
        [[ -f "$__azure_users_dir__/users.sh" ]] && source "$__azure_users_dir__/users.sh";
        [[ -f "$__azure_users_dir__/env.sh" ]] && source "$__azure_users_dir__/env.sh";
    fi

    unset -f __source_azure_functions  # Clean up function after use
    unset __azure_functions_dir__
    unset __azure_users_dir__
}

function __azure_cli_tool_setup() {
    curl -LO https://github.com/Azure/kubelogin/releases/download/v0.2.14/kubelogin-linux-amd64.zip
    unzip kubelogin-linux-amd64.zip -d /usr/local/bin/
    chmod +x /usr/local/bin/kubelogin
}
__source_azure_functions__