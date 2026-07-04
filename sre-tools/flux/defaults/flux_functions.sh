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
