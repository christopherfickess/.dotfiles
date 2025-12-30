#!/bin/bash

function list_kubernetes_objects(){
    echo
    if [ -z $1 ]; then
        echo -e "${YELLOW}Which namespace do you want to search all resources? ${NC}"
        read -p "   :>  " __namespace__

        __namespace__=__namespace__
    else
        __namespace__="${1}"
    fi  

    if kubectl get namespaces | grep $__namespace__; then 
        for __resource__ in $(kubectl api-resources --namespaced=true -o name); do
            if kubectl get $__resource__ -n $__namespace__ &>/dev/null; then
                __resource_count__=$(kubectl get $__resource__ -n $__namespace__ --no-headers 2>/dev/null | wc -l)
                if [ $__resource_count__ -gt 0 ]; then
                    echo -e "Resource Type:${GREEN} $__resource__${NC}"
                    kubectl get $__resource__ -n $__namespace__ 2>/dev/null || true
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
        read -p "   :>  " __selected_cluster__

        kubectl config use-context ${__selected_cluster__}
    else
        kubectl config get-clusters

        echo -e "${YELLOW}Which cluster do you want to switch to?${NC}"
        read -p "   :>  " __selected_cluster__

        kubectl config use-context ${__selected_cluster__}
    fi
}

function exec_into_pod() {
    if [ -z "${1}" ];then 
        echo -e "${YELLOW}Enter the namespace of the pod: ${NC}"
        read -p "   :>  " __namespace__

        echo -e "${YELLOW}Enter the pod name: ${NC}"
        read -p "   :>  " __pod_name__

        echo -e "${YELLOW}Enter the command to execute (default: /bin/sh): ${NC}"
        read -p "   :>  " __command_to_execute__

        if [ -z "${__command_to_execute__}" ]; then
            __command_to_execute__="/bin/sh"
        fi

        kubectl exec -n ${__namespace__} -it ${__pod_name__} -- ${__command_to_execute__}
    else
        if [ -z "${3}" ]; then
            __command_to_execute__="/bin/sh"
        else
            __command_to_execute__="${3}"
        fi

        kubectl exec -n ${2} -it ${1} -- ${__command_to_execute__}
    fi
}
