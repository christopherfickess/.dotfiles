
function help_git_functions() {
    echo -e ""
    echo -e "Git Commands:"
    echo -e "------------------------------------------------------------------------------------------------------"
    __help_git_functions
}

function __help_git_functions() {
    if [[ "$__verbose__" = TRUE ]]; then
        echo -e "     ${YELLOW}clear_credentials_manager${NC}       - Clear Git credentials from Windows Credential Manager."
        echo -e "     ${YELLOW}config_git [name] [email]${NC}       - Set up global Git configuration with optional name and email."
        echo -e "     ${YELLOW}gmmain${NC}                          - Merge the main branch into the current branch."
        echo -e "     ${YELLOW}gfmain${NC}                          - Fetch the latest changes from the main branch."
        echo -e "     ${YELLOW}git lsg${NC}                         - Display pretty graph log of commits."
        echo -e "     ${YELLOW}git last${NC}                        - Show the last commit details."
        echo -e "     ${YELLOW}git lg${NC}                          - Show a one-line graph"
        echo -e "     ${YELLOW}git prune-tags${NC}                  - Prune deleted tags from remote."
        echo -e "     ${YELLOW}git amend${NC}                       - Amend the last commit without changing the message."
        echo -e
    else
        echo -e "     ${YELLOW}config_git [name] [email]${NC}       - Set up global Git configuration."
    fi
}