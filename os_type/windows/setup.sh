
#!/bin/bash


if [[ "$__OS_TYPE" == "wsl" ]]; then
    echo -e "   ${MAGENTA}Inside WSL OS.${NC}"
    [[ -f "$__wsl_dir__/update/wsl_update.sh" ]] && source "$__wsl_dir__/update/wsl_update.sh"
    # Source WSL help functions
else
    echo -e "   ${MAGENTA}Windows OS.${NC}"
    __windows_setup_config_dir__="$__windows_setup_dir__/windows_setup"
    [[ -f "$__wsl_dir__/setup.sh" ]] && source "$__wsl_dir__/setup.sh"
    [[ -f "$__windows_setup_config_dir__/first_time_setup.sh" ]] && source "$__windows_setup_config_dir__/first_time_setup.sh"
    [[ -f "$__windows_setup_dir__/windows_functions/functions.sh" ]] && source "$__windows_setup_dir__/windows_functions/functions.sh"
fi