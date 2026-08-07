[[ -z "${__home_teleport_cluster_name__}" ]] && return

function tshl.home.login() {
    echo -e "${CYAN}Logging into Teleport proxy at ${__home_teleport_server__} as user ${__home_teleport_user__}...${NC}"
    tsh login --proxy="${__home_teleport_server__}" --user="${__home_teleport_user__}" && \
    tsh kube login ${__home_teleport_cluster_name__} && \
    echo -e "${GREEN}Successfully logged into Teleport proxy and Kubernetes cluster.${NC}"
}

function tshl.home.nano (){
    tsh ssh ${__home_teleport_username__}@${__home_nano__}
}

function tshl.home.imac (){
    tsh ssh ${__home_teleport_username__}@${__home_imac__}
}

function tshl.home.reset() { rm -rf ~/.tsh; tshl.home.login; }   # use after any tctl users/roles change