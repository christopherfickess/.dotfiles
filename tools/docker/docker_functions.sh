#!/bin/bash

function start_fedora_docker() {
    echo -e "${GREEN}Starting Fedora Docker...${NC}"
    docker ps

    docker run --rm fedora:latest sleep 120

    docker ps
    docker exec -it fedora-docker /bin/bash
    echo -e "${GREEN}Fedora Docker started successfully.${NC}"
}

function d_exec() {
    
    if [ ! -z"${1}" ]; then
        __CONTAINER_ID__=${1}
    else
        echo -e "    Which container do you want to exec into?"
        docker ps
        read -p "    Enter the container ID: " __CONTAINER_ID__
    fi
    echo -e "${GREEN}Exec into container ${__CONTAINER_ID__}...${NC}"
    docker exec -it ${__CONTAINER_ID__} /bin/bash
}

function d_exec_with_command() {
    
    if [ ! -z"${1}"  && ! -z"${2}" ]; then
        __CONTAINER_ID__=${1}
        __COMMAND__=${2}
    else
        echo -e "    Which container do you want to exec into?"
        docker ps
        read -p "    Enter the container ID: " __CONTAINER_ID__
    fi
    
    echo -e "${GREEN}Executing command in container ${__CONTAINER_ID__}...${NC}"
    docker exec -it ${__CONTAINER_ID__} -- ${__COMMAND__}
}
