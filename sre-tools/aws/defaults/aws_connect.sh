#!/bin/bash

# TELEPORT_LOGIN is set in the tmp/env.sh file
    # e.g., mattermost.com:443

function tshl() {
    if command -v tsh &> /dev/null; then
        echo "Logging into Teleport proxy at ${TELEPORT_LOGIN}..."
        tsh login --proxy "${TELEPORT_LOGIN}" --auth=microsoft
    else
        echo "Teleport CLI (tsh) is not installed. Please install it to log in."
    fi
}


function aws_sts_assume_role(){
    if [[ "${1}" == "-p" && ! -z "${__pal_aws_role}" ]]; then
        __session_name__="christopher.fickess@mattermost.com"

        export AWS_DEFAULT_REGION="us-east-2"
        export AWS_REGION="us-east-2"
        
        palantir
        __role_arn__="${__pal_aws_role}"
        __credentials__=$(aws sts assume-role --role-arn "$__role_arn__" \
                --role-session-name "$__session_name__" \
                --output json)

        export AWS_ACCESS_KEY_ID=$(echo $__credentials__ | jq -r '.Credentials.AccessKeyId')
        export AWS_SECRET_ACCESS_KEY=$(echo $__credentials__ | jq -r '.Credentials.SecretAccessKey')
        export AWS_SESSION_TOKEN=$(echo $__credentials__ | jq -r '.Credentials.SessionToken')


        __check_role_arn__="${__pal_aws_assumed_role}"

    elif [[ "${1}" == "-b" || "${1}" == "--breakglass" ]]; then
        mattermost-breakglass
        __session_name__="christopher.fickess@mattermost.com"
        __role_arn__="${__breakglass_aws_role}/${__session_name__}"

    elif [[ "${1}" == "-d" || "${1}" == "--dev" && ! -z "${__dev_aws_assume_role}" ]]; then
        dev
        __session_name__="christopher.fickess@mattermost.com"

        __check_role_arn__="${__dev_aws_assumed_role}/${__session_name__}"
    elif [[ "${1}" == "-h" || "${1}" == "--help" ]]; then
        __aws_connect_options__
        return
    elif [[ -z "${1}" || -z "${2}" ]];then 
        __aws_connect_options__
        return
    elif [[ ! -z "${1}" && ! -z "${2}" ]]; then
        __role_arn__=${1}
        __session_name__=${2}

        __credentials__=$(aws sts assume-role --role-arn "$__role_arn__" --role-session-name "$__session_name__" --output json)
        
        export AWS_ACCESS_KEY_ID=$(echo $__credentials__ | jq -r '.Credentials.AccessKeyId')
        export AWS_SECRET_ACCESS_KEY=$(echo $__credentials__ | jq -r '.Credentials.SecretAccessKey')
        export AWS_SESSION_TOKEN=$(echo $__credentials__ | jq -r '.Credentials.SessionToken')

        __check_role_arn__="${__role_arn__}/${__session_name__}"
    else
        __aws_connect_options__
        return
    fi

    __check_connection__=$(aws sts get-caller-identity \
        --query 'Arn' \
        --output text)

    if [[ "${__check_role_arn__}" == "${__check_connection__}" ]]; then 
        __output_aws_connection_info__
    else
        echo -e "   ${RED}${__failed_box}${NC}   Roles do not match."
        echo -e "       Expected: ${YELLOW}${__check_role_arn__}${NC}"
        echo -e "       Got:      ${YELLOW}${__check_connection__}${NC}"
        echo
    fi

}

function cluster_connect(){
    if [[ "${1}" == "-p" && ! -z "${__palantir_eks_cluster_name}" ]]; then
        local __cluster_name__="${__pal_eks_cluster_name}"
        export AWS_DEFAULT_REGION="us-east-2"
        export AWS_REGION="us-east-2"
        
    elif [[ "${1}" == "-d" || "${1}" == "--dev" && ! -z "${__dev_eks_cluster_name}" ]]; then
        dev
        local __cluster_name__="${__dev_eks_cluster_name}"
    elif [[ "${1}" == "-h" || "${1}" == "--help" ]]; then
        __aws_eks_cluster_options__
        return
    elif [[ "${1}" == "-p" || "${1}" == "--playground" && -z "${__dev_eks_cluster_name}" ]]; then
        dev
        local __cluster_name__="${__playground_eks_cluster_name}"
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

    local __cluster_name__="${__cluster_name__//[^A-Za-z0-9_-]/}"
    
    local __cluster_output__=$(aws eks --region "${AWS_REGION}" \
            update-kubeconfig --name "${__cluster_name__}" 2>&1)
    local __cluster_exit_code__=$?

    if [ $__cluster_exit_code__ -ne 0 ] || [ -z "$__cluster_output__" ] || echo "$__cluster_output__" | grep -q "error\|Error\|ERROR"; then
        echo -e "   ${RED}✗${NC}   Unable to connect to EKS cluster. Please check your credentials and cluster name."
        echo
        return
    fi
    # local env_tag="${env_tag:-}"
    echo -e "   ${GREEN}✓${NC} Connected to EKS cluster:    ${YELLOW}${__cluster_name__}${NC}"
    echo
}

function ec2_ssm_connection(){
    if [ -z "${_ec2_id}" ];then 
        echo -e "${RED}Pass ec2_id_function for instance id${NC}"
    else
        aws ssm start-session --target ${_ec2_id}
    fi
}

function __aws_connect_options__(){
    
        echo -e "${MAGENTA}Usage:${NC} aws_sts_assume_role [Role ARN] [Session Name]"
        echo -e "       OR"
        echo -e "        aws_sts_assume_role <flags>"
        echo -e "           ${YELLOW}-p${NC}             - Assume Pal AWS role if set in env.sh"
        echo -e "           ${YELLOW}-d${NC}|--dev       - Assume Dev AWS role if set in env.sh"
        echo -e "           ${YELLOW}-h${NC}|--help      - Show this help message"
        echo -e "${YELLOW}This function assumes an AWS IAM role and sets the AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, and AWS_SESSION_TOKEN environment variables.${NC}"
}

function __aws_eks_cluster_options__(){
    echo -e "${MAGENTA}Usage:${NC} aws_eks_connect_cluster [Cluster Name]"
    echo -e "       OR"
    echo -e "       aws_eks_connect_cluster <flag>"
    echo -e "           ${YELLOW}-p${NC}                - Assume Pal AWS role if set in env.sh"
    echo -e "           ${YELLOW}-d|--dev${NC}          - Assume Dev AWS role if set in env.sh"
    echo -e "           ${YELLOW}-h|--help${NC}         - Show this help message"
    echo -e "           ${YELLOW}-p|--playground${NC}   - Connect to Playground EKS cluster if set in env.sh"
    echo -e "${YELLOW}This function connects to an EKS cluster by updating the kubeconfig file.${NC}"
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