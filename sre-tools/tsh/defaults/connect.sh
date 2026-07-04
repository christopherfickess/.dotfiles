
function tshl() {
    if command -v tsh &> /dev/null; then
        echo "Logging into Teleport proxy at ${TELEPORT_LOGIN}..."
        tsh login --proxy "${TELEPORT_LOGIN}" --auth=microsoft
    else
        echo "Teleport CLI (tsh) is not installed. Please install it to log in."
    fi
}

function tshl.login(){
    if command -v tsh &> /dev/null; then
        if [ -z "${TELEPORT_LOGIN}" ]; then
            echo -e "${RED}Please set TELEPORT_LOGIN environment variable before logging in.${NC}"
            return
        fi
        if [ -z "${__customer_name__}" ]; then
            echo -e "${RED}Please set __customer_name__ environment variable before logging in.${NC}"
            return
        fi
        if [ -z "${__tsh_connect_teleport_cluster__}" ]; then
            echo -e "${RED}Please set __tsh_connect_teleport_cluster__ environment variable before logging in.${NC}"
            return
        fi
        echo -e "Logging into Teleport proxy ${MAGENTA}${TELEPORT_LOGIN}${NC}"
        echo -e "    For Customer: ${MAGENTA}${__customer_name__}${NC}..."
        echo
        tsh login --proxy="${TELEPORT_LOGIN}" --auth=microsoft "${__tsh_connect_teleport_cluster__}"
    else
        echo "Teleport CLI (tsh) is not installed. Please install it to log in."
    fi
}

function tshl.connect(){
    if command -v tsh &> /dev/null; then
        if [ -z "${__tsh_connect_eks_cluster__}" ]; then
            echo -e "${RED}Please set __tsh_connect_eks_cluster__ environment variable before connecting.${NC}"
            return
        fi
        echo -e "Connecting to Kubernetes Cluster: ${MAGENTA}${__tsh_connect_eks_cluster__}${NC}..."
        echo
        tsh kube login "${__tsh_connect_eks_cluster__}"
    else
        echo "Teleport CLI (tsh) is not installed. Please install it to log in."
    fi
}
