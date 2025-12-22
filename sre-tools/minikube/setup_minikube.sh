#!/bin/bash

# Setup Minikube in WSL environment

function start_minikube_wsl() {
    echo -e "${GREEN}Starting Minikube in WSL...${NC}"

    if ! command -v minikube > /dev/null; then
        echo -e "${RED}Minikube not found. Please install it first.${NC}"
        exit 1
    fi
    if ! command -v docker > /dev/null; then
        echo -e "${RED}Docker not found. Please install it first.${NC}"
        exit 1
    fi    
    minikube start --driver=docker
    minikube status
    echo -e "${GREEN}Minikube started successfully.${NC}"
}

function destroy_minikube_wsl() {
    echo -e "${GREEN}Stopping and deleting Minikube in WSL...${NC}"

    if ! command -v minikube > /dev/null; then
        echo -e "${RED}Minikube not found. Please install it first.${NC}"
        exit 1
    fi    

    minikube stop
    minikube delete
    echo -e "${GREEN}Minikube stopped and deleted successfully.${NC}"
}

function status_minikube_wsl() {
    echo -e "${GREEN}Checking Minikube status in WSL...${NC}"

    if ! command -v minikube > /dev/null; then
        echo -e "${RED}Minikube not found. Please install it first.${NC}"
        exit 1
    fi    

    minikube status
}

function apply_minikube_wsl() {
    echo -e "${GREEN}Applying Minikube configuration in WSL...${NC}"

    if ! command -v minikube > /dev/null; then
        echo -e "${RED}Minikube not found. Please install it first.${NC}"
        exit 1
    fi    

    minikube addons enable ingress
    minikube addons enable metrics-server
    echo -e "${GREEN}Minikube configuration applied successfully.${NC}"
}