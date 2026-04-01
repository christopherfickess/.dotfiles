#!/bin/bash

function aws.connect.bastion(){
    if [[ -z "${1}" ]]; then
        echo -e "${RED}Please set __bastion_host_name__ environment variable before connecting to bastion host.${NC}"
        return
    else 
        export __bastion_host_name__="${1}"
    fi

    __bastion_host_id=$(aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=${__bastion_host_name__}" \
        --query "Reservations[].Instances[].InstanceId" \
        --output text)

    echo -e "Starting SSM Session to Bastion Host: ${__INFO_COLOR__}${__bastion_host_id}${NC}"

    aws ssm start-session --target "${__bastion_host_id}" \
        --document-name AWS-StartInteractiveCommand \
        --parameters 'command=["sudo -iu ec2-user"]' \
        --profile "${AWS_PROFILE}"
}

function aws.connect.ec2.ssm(){
    if [ -z "${1}" ];then 
        echo -e "${RED}Pass ec2 id for instance id${NC}"
        echo -e "${YELLOW}Example: ${NC}aws.connect.ec2.ssm i-0123456789abcdef0"
        echo -e "${YELLOW}         ${NC}aws.connect.ec2.ssm <instance-id>"
        echo 
        echo -e "Additional useful functions:"
        echo -e "  ${CYAN}aws.get.ec2.id <instance-name>${NC} - Get EC2 instance ID by name"
    else
        export __ec2_id__=$(aws ssm start-session --target "${__ec2_id__}" --profile "${AWS_PROFILE}")
    fi
}


function aws.connect.eks_cluster(){
    if [[ -z "${1}" ]]; then 
        echo -e "${RED}Add the cluster name to proceed! ${NC}"
        return
    else
        local __cluster_name__="${1}"
    fi
    
    local __cluster_output__=$(aws eks --region "${AWS_REGION}" \
            update-kubeconfig --name "${__cluster_name__}" 2>&1)
    local __cluster_exit_code__=$?

    if [ $__cluster_exit_code__ -ne 0 ] || [ -z "$__cluster_output__" ] || echo "$__cluster_output__" | grep -q "error\|Error\|ERROR"; then
        echo -e "   ${RED}✗${NC}   Unable to connect to EKS cluster. Please check your credentials and cluster name."
        echo
        return
    fi
    # local env_tag="${env_tag:-}"
    echo -e "   ${GREEN}✓${NC} Connected to EKS cluster:    ${__INFO_COLOR__}${__cluster_name__}${NC}"
    echo
}

# May be useful but dead right now
function __cluster_connect__(){
    if [[ "${1}" == "-d" || "${1}" == "--dev" && ! -z "${__dev_eks_cluster_name__}" ]]; then
        dev
        local __cluster_name__="${__dev_eks_cluster_name__}"
    elif [[ "${1}" == "-i" || "${1}" == "--iron-badger" && ! -z "${__tsh_iron_badger_staging_eks_cluster__}" ]]; then
        local __cluster_name__="${__tsh_iron_badger_staging_eks_cluster__}"
        tshl.iron-badger.connect
    elif [[ "${1}" == "-h" || "${1}" == "--help" ]]; then
        __aws_eks_cluster_options__
        return
    elif [[ "${1}" == "-p" || "${1}" == "--prod" && ! -z "${__prod_eks_cluster_name__}" ]]; then
        local __cluster_name__="${__prod_eks_cluster_name__}"
        if [[ -z "${prod_mattermost}" ]]; then prod_mattermost; fi
    elif [[ "${1}" == "-s" || "${1}" == "--sandbox" && -z "${__sandbox_eks_cluster_name__}" ]]; then
        dev
        local __cluster_name__="${__sandbox_eks_cluster_name__}"
    elif [[ ! -z "${1}" ]]; then
        local __cluster_name__="${1}"
    elif [[ -z "${1}" ]]; then 
        echo -e "${RED}Add the cluster name to proceed! ${NC}"
        __aws_eks_cluster_options__
        return
    else
        __aws_eks_cluster_options__
        return
    fi

    aws.connect.eks_cluster "${__cluster_name__}"
}

function __aws_connect_options__(){
    
        echo -e "${MAGENTA}Usage:${NC} aws_sts_assume_role [Role ARN] [Session Name]"
        echo -e "       OR"
        echo -e "        aws_sts_assume_role <flags>"
        echo -e "           ${__COMMAND_COLOR__}-d${NC}|--dev       - Assume Dev AWS role if set in env.sh"
        echo -e "           ${__COMMAND_COLOR__}-h${NC}|--help      - Show this help message"
        echo -e "${__INFO_COLOR__}This function assumes an AWS IAM role and sets the AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, and AWS_SESSION_TOKEN environment variables.${NC}"
}

function __aws_eks_cluster_options__(){
    echo -e "${MAGENTA}Usage:${NC} aws_eks_connect_cluster [Cluster Name]"
    echo -e "       OR"
    echo -e "       aws_eks_connect_cluster <flag>"
    echo -e "           ${__COMMAND_COLOR__}-i${NC}                - Connect to iron-badger AWS cluster if set in tsh_connections.sh"
    echo -e "           ${__COMMAND_COLOR__}-d|--dev${NC}          - Connect to Dev AWS cluster if set in tsh_connections.sh"
    echo -e "           ${__COMMAND_COLOR__}-p|--prod${NC}         - Connect to Prod AWS cluster if set in env.sh"
    echo -e "           ${__COMMAND_COLOR__}-h|--help${NC}         - Show this help message"
    echo -e "           ${__COMMAND_COLOR__}-s|--sandbox${NC}   - Connect to sandbox EKS cluster if set in env.sh"
    echo -e "${__INFO_COLOR__}This function connects to an EKS cluster by updating the kubeconfig file.${NC}"
}

function __output_aws_connection_info__() {
    echo
    # Check if AWS account is actually connected
    __aws_output=$(aws sts get-caller-identity --query Arn --output text 2>&1)
    __aws_exit_code=$?
    
    # Check for expired token error
    if echo "$__aws_output" | grep -q "ExpiredToken"; then
        echo -e "   ${RED}${__failed_box}${NC} AWS credentials have expired. Please reconnect to AWS."
        echo
        return 1
    fi
    
    # Check for other connection errors
    if [ $__aws_exit_code -ne 0 ] || [ -z "$__aws_output" ] || echo "$__aws_output" | grep -q "error\|Error\|ERROR"; then
        echo -e "   ${RED}${__failed_box}${NC}   Unable to connect to AWS account. Please check your credentials."
        echo
        return
    fi
    
    # Output just the name of the user not arn
    __user_name="$__aws_output"
    # Create a green checkbox that can be used to indicate success
    __role_name=${__user_name#*/}          # remove everything up to first /
    __role_name=${__role_name%%/*}   # remove everything after next /

    __user_name=${__user_name##*/}
    __user_name="${__user_name}"


    echo -e "   Connected to Role: ${GREEN}${__check_box}   ${__role_name}${NC}"
    echo -e "             As User: ${GREEN}${__check_box}   ${__user_name}${NC}"
    echo 
}