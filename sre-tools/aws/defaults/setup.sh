
__aws_functions_dir__="${__sre_tools_dir__}/aws/defaults"
__aws_users_dir__="$__aws_functions_dir__/users"


function __source_aws_functions() {
    # Use command -v (bash builtin) instead of --version (external command) - much faster
    if command -v aws &>/dev/null; then
    # make a for loop that sources all aws related files in this directory __aws_functions_dir__
        [[ -f "$__aws_functions_dir__/aws_functions.sh" ]] && source "$__aws_functions_dir__/aws_functions.sh"
        [[ -f "$__aws_functions_dir__/aws_connect.sh" ]] && source "$__aws_functions_dir__/aws_connect.sh"
        [[ -f "$__aws_functions_dir__/help.sh" ]] && source "$__aws_functions_dir__/help.sh"
        [[ -f "$__aws_users_dir__/tsl_connections.sh" ]] && source "$__aws_users_dir__/tsl_connections.sh"
        [[ -f "$__aws_users_dir__/users.sh" ]] && source "$__aws_users_dir__/users.sh";
    fi

    unset -f __source_aws_functions  # Clean up function after use
    unset __aws_functions_dir__
    unset __aws_users_dir__
}

__source_aws_functions