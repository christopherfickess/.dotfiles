#!/bin/bash

function setup_bashrc() {
    echo -e "${GREEN}Setting up .bashrc...${NC}"
    
    if [ -f "$HOME/.dotfiles/.bashrc" ]; then
        echo "if [ -f \"\$HOME/.dotfiles/.bashrc\" ]; then  source \"\$HOME/.dotfiles/.bashrc\"; fi" >> $HOME/.bashrc
        source $HOME/.bashrc
        echo -e "${GREEN}.bashrc setup completed.${NC}"
    else
        echo -e "${RED}.dotfiles/.bashrc file not found!${NC}"
    fi
}