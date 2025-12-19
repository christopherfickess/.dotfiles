
function gfmain() { 
    git fetch origin main:main
} 

function gmmain() { 
    git merge main 
} 

function git_fix_creds() {
    # Function to clean up broken Git credentials and help re-authenticate
    # Usage: git_fix_creds
    
    echo -e "🔧 ${CYANR}Fixing Git credentials...${NC}"
    
    # Detect OS type (use the global __OS_TYPE variable if available, otherwise detect)
    local os_type="${__OS_TYPE:-unknown}"
    if [[ "$os_type" == "unknown" ]]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            os_type="macos"
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            if [[ -f /proc/version ]] && grep -qi "microsoft" /proc/version 2>/dev/null; then
                os_type="wsl"
            else
                os_type="linux"
            fi
        else
            local uname_o
            uname_o=$(uname -o 2>/dev/null)
            if [[ "$uname_o" == "Msys" ]] || [[ "$uname_o" == "Cygwin" ]]; then
                os_type="windows"
            elif command -v wsl.exe &>/dev/null && wsl.exe --status &>/dev/null 2>&1; then
                os_type="wsl"
            fi
        fi
    fi
    
    echo -e "   ${YELLOW}Detected OS: ${os_type}${NC}"
    
    # Step 1: Clear Git credential cache
    echo -e "\n${CYANR}Step 1: Clearing Git credential cache...${NC}"
    if git credential-cache exit 2>/dev/null; then
        echo -e "   ${GREEN}✓ Credential cache cleared${NC}"
    else
        echo -e "   ${YELLOW}⚠ No credential cache found (or already cleared)${NC}"
    fi
    
    # Step 2: Clear Git credential store
    echo -e "\n${CYANR}Step 2: Clearing Git credential store...${NC}"
    local cred_helper
    cred_helper=$(git config --global credential.helper 2>/dev/null || echo "")
    if [[ -n "$cred_helper" ]]; then
        echo -e "   ${YELLOW}Current credential helper: ${cred_helper}${NC}"
        
        # Try to erase credentials from store
        if [[ "$cred_helper" == *"store"* ]]; then
            local cred_file="${HOME}/.git-credentials"
            if [[ -f "$cred_file" ]]; then
                echo -e "   ${YELLOW}Removing credential store file: ${cred_file}${NC}"
                rm -f "$cred_file"
                echo -e "   ${GREEN}✓ Credential store file removed${NC}"
            fi
        fi
    else
        echo -e "   ${YELLOW}⚠ No credential helper configured${NC}"
    fi
    
    # Step 3: Clear Windows Credential Manager (for Windows/WSL)
    if [[ "$os_type" == "windows" ]] || [[ "$os_type" == "wsl" ]]; then
        echo -e "\n${CYANR}Step 3: Clearing Windows Credential Manager...${NC}"
        
        if [[ "$os_type" == "wsl" ]]; then
            # In WSL, use cmd.exe to access Windows Credential Manager
            echo -e "   ${YELLOW}Removing Git credentials from Windows Credential Manager...${NC}"
            if command -v cmd.exe &>/dev/null; then
                # List and remove Git credentials
                local cred_list
                cred_list=$(cmd.exe /c "cmdkey /list 2>nul" 2>/dev/null | grep -i "git:" || true)
                
                if [[ -n "$cred_list" ]]; then
                    # Remove common Git credential targets
                    local targets=(
                        "git:https://github.com"
                        "git:https://gitlab.com"
                        "git:https://bitbucket.org"
                    )
                    
                    for target in "${targets[@]}"; do
                        if cmd.exe /c "cmdkey /delete:\"$target\" 2>nul" 2>/dev/null; then
                            echo -e "   ${GREEN}✓ Removed: $target${NC}"
                        fi
                    done
                    
                    # Try to remove any remaining git: entries
                    echo "$cred_list" | while IFS= read -r line; do
                        if [[ "$line" =~ Target:[[:space:]]*(git:.*) ]]; then
                            local target="${BASH_REMATCH[1]}"
                            if cmd.exe /c "cmdkey /delete:\"$target\" 2>nul" 2>/dev/null; then
                                echo -e "   ${GREEN}✓ Removed: $target${NC}"
                            fi
                        fi
                    done
                else
                    echo -e "   ${YELLOW}⚠ No Git credentials found in Windows Credential Manager${NC}"
                fi
            else
                echo -e "   ${YELLOW}⚠ cmd.exe not available in WSL${NC}"
            fi
        else
            # On Windows (Git Bash/MSYS)
            echo -e "   ${YELLOW}Please manually remove Git credentials from Windows Credential Manager:${NC}"
            echo -e "   ${CYAN}1. Open Control Panel → Credential Manager${NC}"
            echo -e "   ${CYAN}2. Go to Windows Credentials${NC}"
            echo -e "   ${CYAN}3. Remove any entries starting with 'git:'${NC}"
        fi
    fi
    
    # Step 4: Reset credential helper configuration
    echo -e "\n${CYANR}Step 4: Resetting credential helper...${NC}"
    local current_helper
    current_helper=$(git config --global credential.helper 2>/dev/null || echo "")
    
    if [[ -n "$current_helper" ]]; then
        echo -e "   ${YELLOW}Current helper: ${current_helper}${NC}"
        echo -e "   ${CYAN}Do you want to reset the credential helper? (y/n)${NC}"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            git config --global --unset credential.helper
            echo -e "   ${GREEN}✓ Credential helper unset${NC}"
            
            # Set appropriate credential helper based on OS
            echo -e "\n   ${CYAN}Setting up credential helper for ${os_type}...${NC}"
            case "$os_type" in
                windows|wsl)
                    git config --global credential.helper manager-core
                    echo -e "   ${GREEN}✓ Set credential helper to 'manager-core' (Windows Credential Manager)${NC}"
                    ;;
                macos)
                    git config --global credential.helper osxkeychain
                    echo -e "   ${GREEN}✓ Set credential helper to 'osxkeychain' (macOS Keychain)${NC}"
                    ;;
                linux)
                    git config --global credential.helper store
                    echo -e "   ${GREEN}✓ Set credential helper to 'store' (plaintext file)${NC}"
                    echo -e "   ${YELLOW}⚠ Note: Consider using SSH keys or a credential manager for better security${NC}"
                    ;;
                *)
                    git config --global credential.helper cache
                    echo -e "   ${GREEN}✓ Set credential helper to 'cache' (temporary memory)${NC}"
                    ;;
            esac
        fi
    else
        echo -e "   ${YELLOW}⚠ No credential helper currently configured${NC}"
        echo -e "   ${CYAN}Do you want to set up a credential helper? (y/n)${NC}"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            case "$os_type" in
                windows|wsl)
                    git config --global credential.helper manager-core
                    echo -e "   ${GREEN}✓ Set credential helper to 'manager-core'${NC}"
                    ;;
                macos)
                    git config --global credential.helper osxkeychain
                    echo -e "   ${GREEN}✓ Set credential helper to 'osxkeychain'${NC}"
                    ;;
                linux)
                    git config --global credential.helper store
                    echo -e "   ${GREEN}✓ Set credential helper to 'store'${NC}"
                    ;;
                *)
                    git config --global credential.helper cache
                    echo -e "   ${GREEN}✓ Set credential helper to 'cache'${NC}"
                    ;;
            esac
        fi
    fi
    
    # Step 5: Provide re-authentication instructions
    echo -e "\n${CYANR}Step 5: Re-authentication instructions${NC}"
    echo -e "   ${GREEN}✓ Credentials have been cleared${NC}"
    echo -e "\n   ${YELLOW}Next steps:${NC}"
    echo -e "   ${CYAN}1. For HTTPS authentication:${NC}"
    echo -e "      ${CYAN}   • GitHub/GitLab no longer accept passwords${NC}"
    echo -e "      ${CYAN}   • Use a Personal Access Token (PAT) instead${NC}"
    echo -e "      ${CYAN}   • When prompted, use your username and PAT as password${NC}"
    echo -e "\n   ${CYAN}2. To test authentication, run:${NC}"
    echo -e "      ${CYAN}   git ls-remote <your-repo-url>${NC}"
    echo -e "\n   ${CYAN}3. Alternative: Use SSH keys (recommended)${NC}"
    echo -e "      ${CYAN}   • Generate SSH key: ssh-keygen -t ed25519 -C \"your_email@example.com\"${NC}"
    echo -e "      ${CYAN}   • Add to GitHub/GitLab: cat ~/.ssh/id_ed25519.pub${NC}"
    echo -e "      ${CYAN}   • Use SSH URLs: git@github.com:user/repo.git${NC}"
    
    echo -e "\n${GREEN}✓ Git credential cleanup complete!${NC}"
    echo -e "   ${YELLOW}Try a Git operation now to re-authenticate.${NC}\n"
}
