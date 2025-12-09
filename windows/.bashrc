#!/bin/bash

# This is the main .bashrc file for Windows WSL setup
# It includes functions and configurations for WSL environment setup
if [ -f "$HOME/.dotfiles/windows/windows_setup/windows_first_time_setup.sh" ]; then  source "$HOME/.dotfiles/windows/windows_setup/windows_first_time_setup.sh"; fi

# Source WSL specific bashrc and setup scripts
if [ -f "$HOME/.dotfiles/windows/wsl/wsl_setup.sh" ]; then  source "$HOME/.dotfiles/windows/wsl/wsl_setup.sh"; fi
if [ -f "$HOME/.dotfiles/windows/wsl/wsl_help.sh" ]; then  source "$HOME/.dotfiles/windows/wsl/wsl_help.sh"; fi
if [ -f "$HOME/.dotfiles/windows/wsl/wsl_update.sh" ]; then  source "$HOME/.dotfiles/windows/wsl/wsl_update.sh"; fi
