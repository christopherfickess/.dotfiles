
function stuck_namespace_fix() {
    if [ -z "$1" ]; then
        echo -e "${RED}Error: No namespace provided. Usage: stuck_namespace_fix <namespace>${NC}"
        return 1
    fi
    NAMESPACE="${1}"

    echo -e "${GREEN}Fixing stuck namespace ${NAMESPACE}...${NC}"
    kubectl get namespace ${NAMESPACE} -o json > ns.json

    echo "Modifying namespace '${NAMESPACE}' to remove stuck finalizers..."
    code ns.json 
    read -p "Hit ENTER to continue..."
    kubectl replace --raw "/api/v1/namespaces/${NAMESPACE}/finalize" -f ./ns.json
    rm ns.json
}