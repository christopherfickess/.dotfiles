#!/bin/bash

function list_kubernetes_objects(){
    echo
    if [ -z $1 ]; then
        echo -e "${YELLOW}Which namespace do you want to search all resources? ${NC}"
        read -p "   :>  " _namespaces

        NAMESPACE=_namespaces
    else
        NAMESPACE=$1
    fi  

    if kubectl get namespaces | grep $NAMESPACE; then 
        for resource in $(kubectl api-resources --namespaced=true -o name); do
            if kubectl get $resource -n $NAMESPACE &>/dev/null; then
                resource_count=$(kubectl get $resource -n $NAMESPACE --no-headers 2>/dev/null | wc -l)
                if [ $resource_count -gt 0 ]; then
                    echo -e "Resource Type:${GREEN} $resource${NC}"
                    kubectl get $resource -n $NAMESPACE 2>/dev/null || true
                    echo
                fi
            fi
        done
    fi 
}