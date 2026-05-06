
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
