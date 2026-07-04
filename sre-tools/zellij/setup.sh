#!/bin/bash

__zellij_functions_dir__="${__sre_tools_dir__}/zellij/defaults"
__zellij_templates_dir__="${__sre_tools_dir__}/zellij/templates"

function __source_zellij_functions() {
    # Check if zellij is installed
    if command -v zellij &>/dev/null; then
        [[ -f "$__zellij_functions_dir__/zellij_functions.sh" ]] && source "$__zellij_functions_dir__/zellij_functions.sh"
        [[ -f "$__zellij_functions_dir__/help.sh" ]] && source "$__zellij_functions_dir__/help.sh"
    else
        echo -e "${YELLOW}Zellij is not installed. Install it from: https://zellij.dev${NC}"
    fi

    unset -f __source_zellij_functions  # Clean up function after use
    unset __zellij_functions_dir__
    unset __zellij_templates_dir__
}

__source_zellij_functions
