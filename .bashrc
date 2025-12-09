# #!/bin/bash

export PATH=$PATH:$HOME/go/bin
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:$HOME/bin

if [ -d "/home/$USER/" ] && [ ! -z "$USER" ]; then export PATH=$PATH:/home/$USER/bin; fi

# Bashrc for Various tools
if [ -f "$HOME/.dotfiles/tools/.bashrc" ]; then  source "$HOME/.dotfiles/tools/.bashrc"; fi

# Check if Windows OS and source windows specific bashrc
if grep -qi "microsoft" /proc/version 2>/dev/null || [[ "$(uname -o 2>/dev/null)" == "Msys" ]] || [[ "$(uname -o 2>/dev/null)" == "Cygwin" ]]; then
    if [ -f "$HOME/.dotfiles/windows/.bashrc" ]; then  source "$HOME/.dotfiles/windows/.bashrc"; fi
    ISWINDOWS=TRUE;
else
    echo "This is NOT Windows"
fi

# This is the helper functions and aliases
if [ -f "$HOME/.dotfiles/help.sh" ]; then  source "$HOME/.dotfiles/help.sh"; fi

# .bashrc 
function branching_method_1 () {
    function git-branch-name {
        git symbolic-ref HEAD 2>/dev/null | cut -d "/" -f 3,4,5
    } 

    function git-branch-prompt {
        local branch=$(git-branch-name) 
        
        if [ $branch ]; then printf "%s " $branch; fi
    } 
    export PS1='\[\033[32m\]$(git-branch-prompt)\[\e[1;34m\]\w\[\033[32m\]\[\e[m\] \[\e[0;31m\]> \[\033[0m\]'
}

function branching_method_2() {
    # Function to get branch name
    git_branch_name() {
        git symbolic-ref --short HEAD 2>/dev/null
    }

    # Function to get ahead count
    git_branch_ahead() {
        local branch=$(git_branch_name)
        if [[ -n "$branch" ]]; then
            local upstream=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
            if [[ -n "$upstream" ]]; then
                local ahead=$(git rev-list --count "$upstream"..HEAD 2>/dev/null)
                if [[ "$ahead" -gt 0 ]]; then
                    printf "↑%s" "$ahead"
                fi
            fi
        fi
    }

    # Export PS1 with separate colors
    export PS1="\[\e[36m\]\w\[\e[0m\] \[\e[32m\][ \$(git_branch_name)\[\e[37m\] \$(git_branch_ahead)\[\e[32m\]]\[\e[0m\] \[\e[0;31m\]> \[\e[0m\]"
}

function branching_method_3() {
    # Get current branch (only if inside git repo)
    git_branch_name() {
        if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            git symbolic-ref --short HEAD 2>/dev/null
        fi
    }

    # Determine default branch
    git_default_branch() {
        if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            if git show-ref --verify --quiet refs/heads/main; then
                echo "main"
            elif git show-ref --verify --quiet refs/heads/master; then
                echo "master"
            fi
        fi
    }

    # Ahead/behind relative to default branch
    git_branch_ahead_behind() {
        if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            return
        fi
        local branch=$(git_branch_name)
        local default_branch=$(git_default_branch)
        if [[ -n "$branch" && -n "$default_branch" ]]; then
            local ahead=$(git rev-list --count "$default_branch"..HEAD 2>/dev/null)
            local behind=$(git rev-list --count HEAD.."$default_branch" 2>/dev/null)
            local str=""
            [[ "$ahead" -gt 0 ]] && str+="↑$ahead"
            [[ "$behind" -gt 0 ]] && str+="↓$behind"
            printf "%s" "$str"
        fi
    }

    # Build branch prompt
    git_branch_prompt() {
        local branch=$(git_branch_name)
        if [[ -n "$branch" ]]; then
            printf "[%s%s]" "$branch" "$(git_branch_ahead_behind)"
        fi
    }

    # Set PS1 depending on shell
    if [ -n "$ZSH_VERSION" ]; then
        # Zsh prompt escapes: %F{color} ... %f for foreground, %B/%b for bold

        fg_bold_black()   { echo "%F{black}%B"; }
        fg_bold_red()     { echo "%F{red}%B"; }
        fg_bold_green()   { echo "%F{green}%B"; }
        fg_bold_yellow()  { echo "%F{yellow}%B"; }
        fg_bold_blue()    { echo "%F{blue}%B"; }
        fg_bold_magenta() { echo "%F{magenta}%B"; }
        fg_bold_cyan()    { echo "%F{cyan}%B"; }
        fg_bold_white()   { echo "%F{white}%B"; }
        fg_bold_reset()   { echo "%b%f"; }  # Reset bold and color

        setopt PROMPT_SUBST  # allows function calls in prompt

        # Define prompt using the functions
        PROMPT='$(fg_bold_yellow)%~$(fg_bold_reset) $(fg_bold_green)$(git_branch_name)$(fg_bold_reset) $(fg_bold_white)$(git_branch_ahead_behind)$(fg_bold_reset) $(fg_bold_red)>$(fg_bold_reset) '

        # Source bashrc if needed for git functions
        [[ -f ~/.bashrc ]] && source ~/.bashrc
    else
        # Bash prompt escapes
        PS1="\[\e[1;34m\]\w\[\e[0m\] \[\e[32m\]\$(git_branch_name)\[\e[0m\]\[\e[37m\] \$(git_branch_ahead_behind)\[\e[0m\] \[\e[0;31m\]> \[\e[0m\]"
    fi
}


branching_method_3
