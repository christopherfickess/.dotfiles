#!/bin/bash


[[ -f "$__wsl_dir__/update/wsl_update.sh" ]] && source "$__wsl_dir__/update/wsl_update.sh"
[[ -f "$__wsl_dir__/help.sh" ]] && source "$__wsl_dir__/help.sh"
[[ -f "$__wsl_dir__/destroy/wsl_destroy.sh" ]] && source "$__wsl_dir__/destroy/wsl_destroy.sh"
[[ -f "$__wsl_dir__/setup/wsl_setup.sh" ]] && source "$__wsl_dir__/setup/wsl_setup.sh"