#!/bin/bash

export __flux_dir__="${__sre_tools_dir__}/flux"
export __flux_functions_dir__="${__flux_dir__}/defaults/"

function __source_flux_functions() {
    # Check if flux is installed
    if command -v flux &>/dev/null; then
        [[ -f "$__flux_dir__/help.sh" ]] && source "$__flux_dir__/help.sh"
        [[ -f "$__flux_functions_dir__/flux_functions.sh" ]] && source "$__flux_functions_dir__/flux_functions.sh"
    else
        echo -e "${YELLOW}Flux is not installed. Install it from: https://fluxcd.io${NC}"
    fi

    unset -f __source_flux_functions  # Clean up function after use
    unset __flux_functions_dir__
    unset __flux_dir__
}

__source_flux_functions
