#!/bin/bash

function update_wsl() {
    echo -e "${GREEN}Updating WSL configurations and scripts...${NC}"

    net session >/dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        echo "Running as root (admin)"
        

        
        before="$(__get_wsl_version__)"

        echo "Checking for WSL updates..."
        wsl.exe --update

        after="$(__get_wsl_version__)"

        if [ -n "$before" ] && [ -n "$after" ] && [ "$before" != "$after" ]; then
            echo "WSL was updated ($before → $after)"
            
            __upgrade_wsl_environment__
            
            echo -e "${GREEN}WSL upgrade completed.${NC}"
        else
            echo "WSL already up to date"
        fi

    else
        echo "Not running as root"
    fi
}


# ------------------
# Secret Functions
# ------------------
function __upgrade_wsl_environment__() {
    # Placeholder for future WSL environment upgrade logic
    echo -e "${GREEN}Checking for WSL environment updates...${NC}"
    
    wsl.exe sh -c "
        WIN_HOME="/mnt/c/Users/${USERNAME}"

        [ -f "$WIN_HOME/.bashrc" ] && \
            grep -qxF "$(cat "$WIN_HOME/.bashrc")" ~/.bashrc || \
            cat "$WIN_HOME/.bashrc" >> ~/.bashrc

        __safe_link__ "$WIN_HOME/.dotfiles"     "$HOME/.dotfiles"
        __safe_link__ "$WIN_HOME/.gitconfig"    "$HOME/.gitconfig"
        __safe_link__ "$WIN_HOME/.git-credentials" "$HOME/.git-credentials"
        __safe_link__ "$WIN_HOME/git"           "$HOME/git"
        __safe_link__ "$WIN_HOME/.aws"           "$HOME/.aws"
        __safe_link__ "$WIN_HOME/.kube"          "$HOME/.kube"
        __safe_link__ "$WIN_HOME/.minikube"      "$HOME/.minikube"
        __safe_link__ "$WIN_HOME/.docker"        "$HOME/.docker"
        __safe_link__ "$WIN_HOME/.ssh"           "$HOME/.ssh"
        __safe_link__ "$WIN_HOME/.tsh"           "$HOME/.tsh"

    echo -e \"${GREEN}== Updating distribution packages ==${NC}\"
    sudo dnf upgrade --refresh -y

    echo -e \"${GREEN}== Updating Python tools ==${NC}\"
    python3 -m pip install --upgrade pip setuptools wheel

    echo -e \"${GREEN}== Updating AWS CLI if installed ==${NC}\"
    if command -v aws &>/dev/null; then
        pip3 install --upgrade awscli
    fi

    echo -e \"${GREEN}== Updating Teleport ==${NC}\"
    if command -v tctl &>/dev/null; then
        if [ -z \"$TELEPORT_VERSION\" ]; then
            echo -e \"${RED}TELEPORT_VERSION is not set. Cannot proceed with the update.${NC}\"
        fi

        if [ -d \"/home/$USERNAME/bin/teleport\" ]; then
            mv /home/$USERNAME/bin/teleport /home/$USERNAME/bin/teleport_backup_$(date +%Y%m%d_%H%M%S)
        fi

        sudo mkdir -p /home/$USERNAME/bin
        echo -e \"${MAGENTA}user name /home/$USERNAME ${TELEPORT_VERSION}...${NC}\"
        pushd /home/$USERNAME/bin >/dev/null
            curl -sO https://cdn.teleport.dev/teleport-$TELEPORT_VERSION-linux-amd64-bin.tar.gz
            tar -xzf teleport-$TELEPORT_VERSION-linux-amd64-bin.tar.gz
            cd teleport
            sudo ./install
        popd >/dev/null
        rm -rf /home/$USERNAME/bin/teleport-$TELEPORT_VERSION-linux-amd64-bin.tar.gz 
        rm -rf /home/$USERNAME/bin/teleport_backup_*
    fi

    echo -e \"${GREEN}== Updating kubectl ==${NC}\"
    if command -v kubectl &>/dev/null; then
        curl -sLO \"https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl\"
        sudo install -m 0755 kubectl /usr/local/bin/kubectl
        rm kubectl
    fi

    echo -e \"${GREEN}== Updating Minikube ==${NC}\"
    if command -v minikube &>/dev/null; then
        curl -sLO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
        sudo install minikube-linux-amd64 /usr/local/bin/minikube
        rm minikube-linux-amd64
    fi

    echo -e \"${GREEN}== Updating kubecolor ==${NC}\"
    if command -v go &>/dev/null; then
        go install github.com/hidetatz/kubecolor/cmd/kubecolor@latest
    fi

    echo -e \"${GREEN}== Updating Docker packages ==${NC}\"
    if command -v docker &>/dev/null; then
        sudo dnf update -y docker* || true
        sudo apt install --only-upgrade docker* -y 2>/dev/null || true
    fi
    "
}



function __safe_link__() {
    local src="$1"
    local dest="$2"

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
            return 0
        else
            echo "Skipping $dest (already exists)"
            return 0
        fi
    fi

    ln -s "$src" "$dest"
}


function __get_wsl_version__() {
    wsl.exe --version 2>/dev/null | \
        iconv -f UTF-16LE -t UTF-8 | \
        awk -F: '/WSL version/ { gsub(/^[ \t]+/, "", $2); print $2 }'
}
