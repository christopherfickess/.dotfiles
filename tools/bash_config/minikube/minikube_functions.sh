
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