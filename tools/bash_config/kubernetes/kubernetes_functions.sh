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


function myhelp_aws_commands() {
    echo -e "AWS Commands:"
    echo -e "------------------------------------------------------------------------------------------------------"
    echo -e "     ${YELLOW}aws_auth_update${NC}                 - Update your AWS credentials file in ~/.aws/credentials"
    echo -e "     ${YELLOW}aws_profile_switch${NC}              - Switch AWS profiles in your terminal"
    echo -e "     ${YELLOW}list_node_group${NC}                 - List all running EC2 instances in the current node group"
    echo -e "     ${YELLOW}ec2_id_function${NC}                 - Get the EC2 instance ID based on the instance name"
    echo -e "     ${YELLOW}ec2_ssm_connection${NC}              - Start an SSM session to the EC2 instance using the ID from ec2_id_function"
    echo -e "     ${YELLOW}list_kubernetes_objects${NC}         - List all Kubernetes objects in a specified namespace"
    echo -e "     ${YELLOW}ssm_parse_command_to_node_id${NC}    - Start an SSM session to a specific EC2 instance and run a command"
}