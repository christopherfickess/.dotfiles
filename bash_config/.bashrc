

if [ -f "$HOME/.dotfiles/bash_config/.bash_aliases" ]; then  source "$HOME/.dotfiles/bash_config/.bash_aliases"; fi
if [ -f "$HOME/.dotfiles/bash_config/.bash_functions" ]; then  source "$HOME/.dotfiles/bash_config/.bash_functions"; fi

if [ -f "$HOME/.dotfiles/bash_config/kubernetes_functions.sh" ]; then  source "$HOME/.dotfiles/bash_config/kubernetes_functions.sh"; fi