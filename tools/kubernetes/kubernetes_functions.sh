#!/bin/bash

function list_kubernetes_objects(){
    echo
    if [ -z $1 ]; then
        echo -e "${YELLOW}Which namespace do you want to search all resources? ${NC}"
        read -p "   :>  " _namespaces

        NAMESPACE=_namespaces
    else
        NAMESPACE="${1}"
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

function which_cluster() { 
    kubectl config current-context 
} 

function switch_cluster(){
    if [ -z "${1}" ];then 
        echo -e "${YELLOW}Enter the cluster name to switch to: ${NC}"
        read -p "   :>  " selected_cluster

        kubectl config use-context ${selected_cluster}
    else
        kubectl config get-clusters

        echo -e "${YELLOW}Which cluster do you want to switch to?${NC}"
        read -p "   :>  " selected_cluster

        kubectl config use-context ${selected_cluster}
    fi
}

function exec_into_pod() {
    if [ -z "${1}" ];then 
        echo -e "${YELLOW}Enter the namespace of the pod: ${NC}"
        read -p "   :>  " pod_namespace

        echo -e "${YELLOW}Enter the pod name: ${NC}"
        read -p "   :>  " pod_name

        echo -e "${YELLOW}Enter the command to execute (default: /bin/sh): ${NC}"
        read -p "   :>  " command_to_execute

        if [ -z "${command_to_execute}" ]; then
            command_to_execute="/bin/sh"
        fi

        kubectl exec -n ${pod_namespace} -it ${pod_name} -- ${command_to_execute}
    else
        if [ -z "${3}" ]; then
            command_to_execute="/bin/sh"
        else
            command_to_execute="${3}"
        fi

        kubectl exec -n ${2} -it ${1} -- ${command_to_execute}
    fi
}
