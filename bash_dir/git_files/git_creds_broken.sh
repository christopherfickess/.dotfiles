
function clear_credentials_manager() {
    echo -e "${CYAN}Clearing Git credentials from Windows Credential Manager...${NC}"
        git config --global --unset-all credential.helper; 
        git config --global --unset-all credential.helper
        echo -e "   ${YELLOW}Get new PAT in Github...${NC}"
        echo -e "       - Go to"
        echo -e "          - https://github.com/settings/tokens"
        echo -e "       - Click on 'Generate new token'"
        echo -e "       - Select appropriate scopes (repo, workflow, etc.)"
        echo -e "       - Generate token and copy it"
        echo -e "   ${YELLOW}Next time you do a git operation that requires authentication, you will be prompted to enter your username and the new PAT as the password.${NC}"
    done
    echo -e "${GREEN}Git credentials cleared from Windows Credential Manager.${NC}"
}