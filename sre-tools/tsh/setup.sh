
export __tshl_functions_dir__="${__sre_tools_dir__}/tsh"

function __source_tshl_default_setup__() {
    # Source the main connect script

    if command -v tsh &>/dev/null; then
        source "${__tshl_functions_dir__}/defaults/connect.sh"

        # Source user-specific connection scripts
        for file in "${__tshl_functions_dir__}/defaults/users/"*.sh; do
            [ -e "$file" ] && source "$file"
        done

        unset -f __source_tshl_default_setup__  # Clean up function after use
        unset __tshl_functions_dir__
    else
        echo -e "${RED}TSH is not installed. Please install it to use tsh functions.${NC}"
        echo -e "If you want to install it now, please run the following command:"
        echo -e "${CYAN}__install_tshl__${NC}"

        unset -f __source_tshl_default_setup__  # Clean up function after use
        unset __tshl_functions_dir__
        return
    fi    
}

function __install_tshl__(){
    # Windows os
    if [[ "$OSTYPE" == "msys" ]]; then
        echo -e "${YELLOW}Please install Teleport CLI (tsh) for Windows from the official website:${NC}"
        echo -e "${CYAN}https://goteleport.com/teleport/download/${NC}"
        echo -e "After installing, please restart your terminal and run ${MAGENTA}tsh login${NC} to log in."
    else
        echo -e "${YELLOW}Please install Teleport CLI (tsh) for your operating system from the official website:${NC}"
        echo -e "${CYAN}https://goteleport.com/teleport/download/${NC}"
        echo -e "After installing, please restart your terminal and run ${MAGENTA}tsh login${NC} to log in."
    fi

    # if mac os, suggest installing with homebrew
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo -e "${YELLOW}On macOS, Using Homebrew to install:${NC}"
        echo -e "    Do you wish to install Teleport CLI (tsh) using Homebrew? (y/n)"
        read -r answer
        if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
            if command -v brew &>/dev/null; then
                brew install teleport
                echo -e "After installing, please run ${MAGENTA}tsh login${NC} to log in."
            else
                echo -e "${RED}Homebrew is not installed. Please install Homebrew first or install Teleport CLI (tsh) manually from the official website:${NC}"
                echo -e "${CYAN}https://goteleport.com/teleport/download/${NC}"
                echo -e "After installing, please run ${MAGENTA}tsh login${NC} to log in."
            fi
        fi
    fi

    # if linux os, suggest installing with apt or yum depending on distro
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo -e "${YELLOW}On Linux, you can install Teleport CLI (tsh) using your package manager or from the official website:${NC}"
        echo -e "    Do you wish to install Teleport CLI (tsh) using your package manager? (y/n)"
        read -r answer
        if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
            if command -v apt &>/dev/null; then
                echo -e "${YELLOW}Installing Teleport CLI (tsh) using apt...${NC}"
                curl https://deb.releases.teleport.dev/teleport-pubkey.asc | sudo apt-key add -
                echo "deb https://deb.releases.teleport.dev/ stable main" | sudo tee /etc/apt/sources.list.d/teleport.list
                sudo apt update
                sudo apt install teleport
                echo -e "After installing, please run ${MAGENTA}tsh login${NC} to log in."
            elif command -v yum &>/dev/null; then
                echo -e "${YELLOW}Installing Teleport CLI (tsh) using yum...${NC}"
                sudo yum install -y yum-utils   
                sudo yum-config-manager --add-repo https://rpm.releases.teleport.dev/teleport.repo
                sudo yum install teleport
                echo -e "After installing, please run ${MAGENTA}tsh login${NC} to log in."
            elif command -v dnf &>/dev/null; then
                echo -e "${YELLOW}Installing Teleport CLI (tsh) using dnf...${NC}"
                sudo dnf install -y dnf-plugins-core
                sudo dnf config-manager --add-repo https://rpm.releases.teleport.dev/teleport.repo
                sudo dnf install teleport
                echo -e "After installing, please run ${MAGENTA}tsh login${NC} to log in."
            else
                echo -e "${RED}No supported package manager found. Please install Teleport CLI (tsh) manually from the official website:${NC}"
                echo -e "${CYAN}https://goteleport.com/teleport/download/${NC}"
                echo -e "After installing, please run ${MAGENTA}tsh login${NC} to log in."
            fi
        fi
    fi
    unset -f __install_tshl__
}

__source_tshl_default_setup__