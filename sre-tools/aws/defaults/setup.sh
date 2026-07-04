
__aws_functions_dir__="${__sre_tools_dir__}/aws/defaults"
__aws_users_dir__="$__aws_functions_dir__/users"


function __source_aws_functions() {
    # Use command -v (bash builtin) instead of --version (external command) - much faster
    if command -v aws &>/dev/null; then
    # make a for loop that sources all aws related files in this directory __aws_functions_dir__
    for file in "$__aws_functions_dir__"/*.sh; do
        if [[ "$file" != "$__aws_functions_dir__/setup.sh" ]]; then
            [[ -f "$file" ]] && source "$file"
        fi
    done

    for file in "$__aws_users_dir__"/*.sh; do
        [[ -f "$file" ]] && source "$file"
    done

    fi


    unset -f __source_aws_functions  # Clean up function after use
    unset __aws_functions_dir__
    unset __aws_users_dir__
}

__source_aws_functions