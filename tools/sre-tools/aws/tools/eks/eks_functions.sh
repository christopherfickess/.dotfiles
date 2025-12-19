#!/bin/bash
# ------------------
# EKS Deployment and Testing Functions
# ------------------

function eks_list_clusters() {
    local region="${AWS_REGION:-us-east-1}"
    
    echo -e "${CYAN}Listing EKS clusters in region: ${region}...${NC}"
    aws eks list-clusters --region "${region}" --output table
}

function eks_cluster_info() {
    local cluster_name="${1}"
    local region="${AWS_REGION:-us-east-1}"
    
    if [ -z "${cluster_name}" ]; then
        echo -e "${RED}Usage: eks_cluster_info <cluster-name> [region]${NC}"
        return 1
    fi
    
    echo -e "${CYAN}Getting info for cluster: ${cluster_name}${NC}"
    aws eks describe-cluster --name "${cluster_name}" --region "${region}" --output json | jq '.'
}

function eks_node_groups() {
    local cluster_name="${1}"
    local region="${AWS_REGION:-us-east-1}"
    
    if [ -z "${cluster_name}" ]; then
        echo -e "${RED}Usage: eks_node_groups <cluster-name> [region]${NC}"
        return 1
    fi
    
    echo -e "${CYAN}Listing node groups for cluster: ${cluster_name}${NC}"
    aws eks list-nodegroups --cluster-name "${cluster_name}" --region "${region}" --output table
}

function eks_update_kubeconfig() {
    local cluster_name="${1}"
    local region="${AWS_REGION:-us-east-1}"
    
    if [ -z "${cluster_name}" ]; then
        echo -e "${RED}Usage: eks_update_kubeconfig <cluster-name> [region]${NC}"
        return 1
    fi
    
    echo -e "${GREEN}Updating kubeconfig for cluster: ${cluster_name}${NC}"
    aws eks update-kubeconfig --name "${cluster_name}" --region "${region}"
    echo -e "${GREEN}Current context: $(kubectl config current-context)${NC}"
}
