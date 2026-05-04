function flux.status() {
    if [[ -z "${1}" || -z "${2}" || -z "${3}" ]]; then 
        echo -e "${RED}Usage: flux.status <namespace> <kustomization-name> <type>${NC}"
        return
    fi
    local namespace="$1"
    local kustomizations="$2"
    local type="${3}"

    flux get ${type} ${kustomizations} -n ${namespace}
}

function flux.suspend() {
    if [[ -z "${1}" || -z "${2}" || -z "${3}" ]]; then 
        echo -e "${RED}Usage: flux.suspend <namespace> <kustomization-name> <type>${NC}"
        return
    fi
    local namespace="$1"
    local kustomizations="$2"
    local type="${3}"

    flux suspend ${type} ${kustomizations} -n ${namespace}
}

function flux.resume() {
    if [[ -z "${1}" || -z "${2}" || -z "${3}" ]]; then 
        echo -e "${RED}Usage: flux.resume <namespace> <kustomization-name> <type>${NC}"
        return
    fi
    local namespace="$1"
    local kustomizations="$2"
    local type="${3}"

    flux resume ${type} ${kustomizations} -n ${namespace}
}

function flux.reconcile() {
    if [[ -z "${1}" || -z "${2}" || -z "${3}" ]]; then 
        echo -e "${RED}Usage: flux.reconcile <namespace> <kustomization-name> <type> [force]${NC}"
        return
    fi
    local namespace="$1"
    local kustomizations="$2"
    local type="${3}"
    local force="${4:-false}"

    if [[ "${force}" == "true" ]]; then
        flux reconcile ${type} ${kustomizations} -n ${namespace} --with-source --force
    else
        flux reconcile ${type} ${kustomizations} -n ${namespace} --with-source
    fi
}

function flux.menu() {
    echo -e "Usage: ${CYAN}flux.menu <namespace> <kustomization-name> <type> [force]${NC}"
    echo -e "  ${CYAN}namespace${NC}: The Kubernetes namespace where the kustomization is deployed."
    echo -e "  ${CYAN}kustomization-name${NC}: The name of the kustomization to manage."
    echo -e "  ${CYAN}type${NC}: The type of resource (e.g., kustomization, helmrelease)."
    echo -e "  ${CYAN}force${NC} (optional): Set to 'true' to force reconciliation, otherwise defaults to 'false'."
}

function myhelp.flux() {
    echo -e "Flux Management Functions:"
    echo -e "  ${CYAN}flux.status <namespace> <kustomization-name> <type>${NC} - Get the status of a Flux resource."
    echo -e "  ${CYAN}flux.suspend <namespace> <kustomization-name> <type>${NC} - Suspend a Flux resource."
    echo -e "  ${CYAN}flux.resume <namespace> <kustomization-name> <type>${NC} - Resume a suspended Flux resource."
    echo -e "  ${CYAN}flux.reconcile <namespace> <kustomization-name> <type> [force]${NC} - Reconcile a Flux resource, optionally forcing it."
    echo -e "  ${CYAN}flux.menu${NC} - Display usage information for Flux management functions."
}
